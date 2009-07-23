From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH] sky2: remove unnecessary assignment
Date: Thu, 23 Jul 2009 11:53:58 +0900
Message-ID: <392fb48f0907221953j77b8ea0etcad115f9b2c99c7b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f213.google.com ([209.85.217.213]:52156 "EHLO
	mail-gx0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751958AbZGWCx7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2009 22:53:59 -0400
Received: by gxk9 with SMTP id 9so1178235gxk.13
        for <netdev@vger.kernel.org>; Wed, 22 Jul 2009 19:53:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Mike McCormack <mikem@ring3k.org>
Acked-by: Stephen Hemminger <shemminger@vyatta.com>
---
 drivers/net/sky2.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 3550c5d..661abd0 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -4117,7 +4117,7 @@ static int sky2_debug_show(struct seq_file *seq, void *v)

 	seq_printf(seq, "\nRx ring hw get=%d put=%d last=%d\n",
 		   sky2_read16(hw, Y2_QADDR(rxqaddr[port], PREF_UNIT_GET_IDX)),
-		   last = sky2_read16(hw, Y2_QADDR(rxqaddr[port], PREF_UNIT_PUT_IDX)),
+		   sky2_read16(hw, Y2_QADDR(rxqaddr[port], PREF_UNIT_PUT_IDX)),
 		   sky2_read16(hw, Y2_QADDR(rxqaddr[port], PREF_UNIT_LAST_IDX)));

 	sky2_read32(hw, B0_Y2_SP_LISR);
-- 
1.5.6.5
