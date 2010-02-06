From: Jan Luebbe <jluebbe@debian.org>
Subject: [PATCH] net/sched: Fix module name in Kconfig
Date: Sat,  6 Feb 2010 18:40:49 +0100
Message-ID: <1265478049-29736-1-git-send-email-jluebbe@debian.org>
Cc: netdev@vger.kernel.org, Jan Luebbe <jluebbe@debian.org>
To: Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sirius.lasnet.de ([78.47.116.19]:36123 "EHLO sirius.lasnet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755773Ab0BFScx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Feb 2010 13:32:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The action modules have been prefixed with 'act_', but the Kconfig
description was not changed.

Signed-off-by: Jan Luebbe <jluebbe@debian.org>
---
 net/sched/Kconfig |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 929218a..21f9c76 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -433,7 +433,7 @@ config NET_ACT_POLICE
 	  module.
 
 	  To compile this code as a module, choose M here: the
-	  module will be called police.
+	  module will be called act_police.
 
 config NET_ACT_GACT
         tristate "Generic actions"
@@ -443,7 +443,7 @@ config NET_ACT_GACT
 	  accepting packets.
 
 	  To compile this code as a module, choose M here: the
-	  module will be called gact.
+	  module will be called act_gact.
 
 config GACT_PROB
         bool "Probability support"
@@ -459,7 +459,7 @@ config NET_ACT_MIRRED
 	  other devices.
 
 	  To compile this code as a module, choose M here: the
-	  module will be called mirred.
+	  module will be called act_mirred.
 
 config NET_ACT_IPT
         tristate "IPtables targets"
@@ -469,7 +469,7 @@ config NET_ACT_IPT
 	  classification.
 
 	  To compile this code as a module, choose M here: the
-	  module will be called ipt.
+	  module will be called act_ipt.
 
 config NET_ACT_NAT
         tristate "Stateless NAT"
@@ -479,7 +479,7 @@ config NET_ACT_NAT
 	  netfilter for NAT unless you know what you are doing.
 
 	  To compile this code as a module, choose M here: the
-	  module will be called nat.
+	  module will be called act_nat.
 
 config NET_ACT_PEDIT
         tristate "Packet Editing"
@@ -488,7 +488,7 @@ config NET_ACT_PEDIT
 	  Say Y here if you want to mangle the content of packets.
 
 	  To compile this code as a module, choose M here: the
-	  module will be called pedit.
+	  module will be called act_pedit.
 
 config NET_ACT_SIMP
         tristate "Simple Example (Debug)"
@@ -502,7 +502,7 @@ config NET_ACT_SIMP
 	  If unsure, say N.
 
 	  To compile this code as a module, choose M here: the
-	  module will be called simple.
+	  module will be called act_simple.
 
 config NET_ACT_SKBEDIT
         tristate "SKB Editing"
@@ -513,7 +513,7 @@ config NET_ACT_SKBEDIT
 	  If unsure, say N.
 
 	  To compile this code as a module, choose M here: the
-	  module will be called skbedit.
+	  module will be called act_skbedit.
 
 config NET_CLS_IND
 	bool "Incoming device classification"
-- 
1.6.6.1

