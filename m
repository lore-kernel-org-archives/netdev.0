From: <jie.yang@atheros.com>
Subject: [patch net-next]atl1c: duplicate atl1c_get_tpd
Date: Wed, 28 Oct 2009 13:14:15 +0800
Message-ID: <12567068551959-git-send-email-jie.yang@atheros.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Jie Yang <jie.yang@atheros.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.atheros.com ([12.36.123.2]:14782 "EHLO mail.atheros.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757313AbZJ1FOT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Oct 2009 01:14:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jie Yang <jie.yang@atheros.com>

remove duplicate atl1c_get_tpd, it may cause hardware to send wrong packets.

Signed-off-by: Jie Yang <jie.yang@atheros.com>

---

 drivers/net/atl1c/atl1c_main.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/atl1c/atl1c_main.c b/drivers/net/atl1c/atl1c_main.c
index 1372e9a..3b8801a 100644
--- a/drivers/net/atl1c/atl1c_main.c
+++ b/drivers/net/atl1c/atl1c_main.c
@@ -1981,8 +1981,6 @@ static void atl1c_tx_map(struct atl1c_adapter *adapter,
 		else {
 			use_tpd = atl1c_get_tpd(adapter, type);
 			memcpy(use_tpd, tpd, sizeof(struct atl1c_tpd_desc));
-			use_tpd = atl1c_get_tpd(adapter, type);
-			memcpy(use_tpd, tpd, sizeof(struct atl1c_tpd_desc));
 		}
 		buffer_info = atl1c_get_tx_buffer(adapter, use_tpd);
 		buffer_info->length = buf_len - mapped_len;
