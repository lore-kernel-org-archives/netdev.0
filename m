From: kaber@trash.net
Subject: [PATCH 07/84] netfilter: xtables: add comment markers to Xtables Kconfig
Date: Mon, 10 May 2010 22:17:38 +0200
Message-ID: <1273522735-24672-8-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54508 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756640Ab0EJUS7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 16:18:59 -0400
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 net/netfilter/Kconfig |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 18d77b5..abf4ce6 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -316,6 +316,8 @@ if NETFILTER_XTABLES
 
 # alphabetically ordered list of targets
 
+comment "Xtables targets"
+
 config NETFILTER_XT_TARGET_CLASSIFY
 	tristate '"CLASSIFY" target support'
 	depends on NETFILTER_ADVANCED
@@ -552,6 +554,10 @@ config NETFILTER_XT_TARGET_TCPOPTSTRIP
 	  This option adds a "TCPOPTSTRIP" target, which allows you to strip
 	  TCP options from TCP packets.
 
+# alphabetically ordered list of matches
+
+comment "Xtables matches"
+
 config NETFILTER_XT_MATCH_CLUSTER
 	tristate '"cluster" match support'
 	depends on NF_CONNTRACK
-- 
1.7.0.4

