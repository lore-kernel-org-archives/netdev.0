From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] unexport xfrm_policy_delete
Date: Tue, 18 Jan 2005 11:29:32 +0100
Message-ID: <20050118102932.GD4274@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261212AbVARK3g@vger.kernel.org>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I haven't found any way how xfrm_policy_delete could be called from 
modular code in 2.6.11-rc1-mm1.

Unless I'm wrong or a patch for a modular usage is pending, I'm 
therefore suggesting this patch for removing the EXPORT_SYMBOL.


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.11-rc1-mm1-full/net/xfrm/xfrm_policy.c.old	2005-01-18 11:11:34.000000000 +0100
+++ linux-2.6.11-rc1-mm1-full/net/xfrm/xfrm_policy.c	2005-01-18 11:11:39.000000000 +0100
@@ -549,8 +549,6 @@
 	}
 }
 
-EXPORT_SYMBOL(xfrm_policy_delete);
-
 int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol)
 {
 	struct xfrm_policy *old_pol;
