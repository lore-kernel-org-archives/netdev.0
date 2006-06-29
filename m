From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] net/xfrm/xfrm_state: unexport xfrm_state_mtu
Date: Thu, 29 Jun 2006 21:20:35 +0200
Message-ID: <20060629192035.GT19712@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from [141.84.69.5] ([141.84.69.5]:30224 "HELO mailout.stusta.mhn.de")
	by vger.kernel.org with SMTP id S932266AbWF2TVc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2006 15:21:32 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch removes the unused EXPORT_SYMBOL(xfrm_state_mtu).

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

This patch was already sent on:
- 12 Apr 2006

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


