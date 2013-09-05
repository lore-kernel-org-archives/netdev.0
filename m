From: Dave Jones <davej@redhat.com>
Subject: [PATCH] Add missing braces to multiline if in cfctrl_linkup_request
Date: Thu, 5 Sep 2013 00:11:19 -0400
Message-ID: <20130905041119.GC15824@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: dmitry.tarnyagin@lockless.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31507 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750701Ab3IEEL3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Sep 2013 00:11:29 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The indentation here implies this was meant to be a multi-line if.

Introduced several years back in commit c85c2951d4da1236e32f1858db418221e624aba5
("caif: Handle dev_queue_xmit errors.")

Signed-off-by: Dave Jones <davej@fedoraproject.org>

diff --git a/net/caif/cfctrl.c b/net/caif/cfctrl.c
index 2bd4b58..0f45522 100644
--- a/net/caif/cfctrl.c
+++ b/net/caif/cfctrl.c
@@ -293,9 +293,10 @@ int cfctrl_linkup_request(struct cflayer *layer,
 
 		count = cfctrl_cancel_req(&cfctrl->serv.layer,
 						user_layer);
-		if (count != 1)
+		if (count != 1) {
 			pr_err("Could not remove request (%d)", count);
 			return -ENODEV;
+		}
 	}
 	return 0;
 }
