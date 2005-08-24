From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] include/net/ip_vs.h: "extern inline" -> "static inline"
Date: Wed, 24 Aug 2005 17:58:06 +0200
Message-ID: <20050824155806.GF4851@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751083AbVHXP6J@vger.kernel.org>
To: wensong@linux-vs.org, ja@ssi.bg
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"extern inline" doesn't make much sense.


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.13-rc6-mm2-full/include/net/ip_vs.h.old	2005-08-24 16:51:58.000000000 +0200
+++ linux-2.6.13-rc6-mm2-full/include/net/ip_vs.h	2005-08-24 16:51:38.000000000 +0200
@@ -958,7 +958,7 @@
  */
 #define IP_VS_FWD_METHOD(cp)  (cp->flags & IP_VS_CONN_F_FWD_MASK)
 
-extern __inline__ char ip_vs_fwd_tag(struct ip_vs_conn *cp)
+static inline char ip_vs_fwd_tag(struct ip_vs_conn *cp)
 {
 	char fwd;
 
