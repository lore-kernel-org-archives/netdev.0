From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: [PATCH 2.6.18] WE-21 for ray_cs
Date: Tue, 29 Aug 2006 18:04:09 -0700
Message-ID: <20060830010409.GI8405@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from gundega.hpl.hp.com ([192.6.19.190]:33535 "EHLO
	gundega.hpl.hp.com") by vger.kernel.org with ESMTP id S932109AbWH3BEz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 21:04:55 -0400
To: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

        Hi,

        WE-21 for Raylink driver...

        Jean

Signed-off-by: Jean Tourrilhes <jt@hpl.hp.com>

-----------------------------------------------------------

diff -u -p linux/drivers/net/wireless/ray_cs.20.c linux/drivers/net/wireless/ray_cs.c
--- linux/drivers/net/wireless/ray_cs.20.c	2006-08-28 17:39:54.000000000 -0700
+++ linux/drivers/net/wireless/ray_cs.c	2006-08-28 17:40:02.000000000 -0700
@@ -1173,7 +1173,7 @@ static int ray_set_essid(struct net_devi
 		return -EOPNOTSUPP;
 	} else {
 		/* Check the size of the string */
-		if(dwrq->length > IW_ESSID_MAX_SIZE + 1) {
+		if(dwrq->length > IW_ESSID_MAX_SIZE) {
 			return -E2BIG;
 		}
 
