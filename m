From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] WE-21 for zd1211rw
Date: Wed, 30 Aug 2006 03:46:27 +0100 (BST)
Message-ID: <20060830024627.0DC5E7B40A0@zog.reactivated.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout03-winn.ispmail.ntl.com ([81.103.221.49]:20495 "EHLO
	mtaout03-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1751460AbWH3CoH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 22:44:07 -0400
To: linville@tuxdriver.com
Cc: kune@deine-taler.de
Cc: jt@hpl.hp.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Looks like zd1211rw was forgotten from the WE-21 migration. This patch
should do it...

Signed-off-by: Daniel Drake <dsd@gentoo.org>
---
 zd_netdev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

Index: linux-2.6/drivers/net/wireless/zd1211rw/zd_netdev.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_netdev.c
+++ linux-2.6/drivers/net/wireless/zd1211rw/zd_netdev.c
@@ -82,7 +82,7 @@ static int iw_get_nick(struct net_device
 		       union iwreq_data *req, char *extra)
 {
 	strcpy(extra, "zd1211");
-	req->data.length = strlen(extra) + 1;
+	req->data.length = strlen(extra);
 	req->data.flags = 1;
 	return 0;
 }
