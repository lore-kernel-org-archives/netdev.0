From: Adrian Bunk <bunk@stusta.de>
Subject: [RFC: 2.6 patch] let NET_CLS_ACT no longer depend on EXPERIMENTAL
Date: Sat, 4 Mar 2006 17:07:55 +0100
Message-ID: <20060304160755.GB9295@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751831AbWCDQH4@vger.kernel.org>
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This option should IMHO no longer depend on EXPERIMENTAL.


Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

This patch was already sent on:
- 12 Feb 2006

--- linux-2.6.16-rc2-mm1-full/net/sched/Kconfig.old	2006-02-12 02:21:30.000000000 +0100
+++ linux-2.6.16-rc2-mm1-full/net/sched/Kconfig	2006-02-12 02:21:58.000000000 +0100
@@ -434,7 +434,6 @@
 
 config NET_CLS_ACT
 	bool "Actions"
-	depends on EXPERIMENTAL
 	select NET_ESTIMATOR
 	---help---
 	  Say Y here if you want to use traffic control actions. Actions
