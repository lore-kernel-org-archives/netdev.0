From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] net/xfrm/xfrm_state: unexport xfrm_state_mtu
Date: Wed, 12 Apr 2006 22:54:56 +0200
Message-ID: <20060412205456.GE6517@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:11016 "HELO
	mailout.stusta.mhn.de") by vger.kernel.org with SMTP
	id S932237AbWDLUy5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Apr 2006 16:54:57 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch removes the unused EXPORT_SYMBOL(xfrm_state_mtu).

Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.17-rc1-mm2-full/net/xfrm/xfrm_state.c.old	2006-04-12 22:38:57.000000000 +0200
+++ linux-2.6.17-rc1-mm2-full/net/xfrm/xfrm_state.c	2006-04-12 22:39:03.000000000 +0200
@@ -1152,8 +1152,6 @@
 	return res;
 }
 
-EXPORT_SYMBOL(xfrm_state_mtu);
-
 int xfrm_init_state(struct xfrm_state *x)
 {
 	struct xfrm_state_afinfo *afinfo;

