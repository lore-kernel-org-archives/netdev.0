From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 1/5] Bluetooth: Fix PTR_ERR return of wrong pointer in hidp_setup_hid()
Date: Thu, 17 Dec 2009 12:22:43 -0800
Message-ID: <971beb83aeb2a309175682cf5683d64fd4591841.1261080894.git.marcel@holtmann.org>
References: <cover.1261080894.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:33950 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765328AbZLQUXS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 15:23:18 -0500
In-Reply-To: <cover.1261080894.git.marcel@holtmann.org>
In-Reply-To: <cover.1261080894.git.marcel@holtmann.org>
References: <cover.1261080894.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>

Return the PTR_ERR of the correct pointer.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/hidp/core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/bluetooth/hidp/core.c b/net/bluetooth/hidp/core.c
index 5697500..18e7f5a 100644
--- a/net/bluetooth/hidp/core.c
+++ b/net/bluetooth/hidp/core.c
@@ -770,7 +770,7 @@ static int hidp_setup_hid(struct hidp_session *session,
 
 	hid = hid_allocate_device();
 	if (IS_ERR(hid))
-		return PTR_ERR(session->hid);
+		return PTR_ERR(hid);
 
 	session->hid = hid;
 	session->req = req;
-- 
1.6.5.2

