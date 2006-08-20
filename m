From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] net/atm/: proper prototypes
Date: Mon, 21 Aug 2006 01:00:06 +0200
Message-ID: <20060820230006.GW7813@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751788AbWHTXAK@vger.kernel.org>
To: chas@cmf.nrl.navy.mil
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds proper prototypes in net/atm/mpc.h for two global 
functions in net/atm/mpoa_proc.c

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 net/atm/mpc.c |    5 -----
 net/atm/mpc.h |    3 +++
 2 files changed, 3 insertions(+), 5 deletions(-)

--- linux-2.6.18-rc4-mm2/net/atm/mpc.h.old	2006-08-20 23:24:37.000000000 +0200
+++ linux-2.6.18-rc4-mm2/net/atm/mpc.h	2006-08-20 23:25:13.000000000 +0200
@@ -50,4 +50,7 @@
 struct seq_file;
 void atm_mpoa_disp_qos(struct seq_file *m);
 
+int mpc_proc_init(void);
+void mpc_proc_clean(void);
+
 #endif /* _MPC_H_ */
--- linux-2.6.18-rc4-mm2/net/atm/mpc.c.old	2006-08-20 23:25:26.000000000 +0200
+++ linux-2.6.18-rc4-mm2/net/atm/mpc.c	2006-08-20 23:25:49.000000000 +0200
@@ -98,11 +98,6 @@
 	0
 };
 
-#ifdef CONFIG_PROC_FS
-extern int mpc_proc_init(void);
-extern void mpc_proc_clean(void);
-#endif
-
 struct mpoa_client *mpcs = NULL; /* FIXME */
 static struct atm_mpoa_qos *qos_head = NULL;
 static DEFINE_TIMER(mpc_timer, NULL, 0, 0);
