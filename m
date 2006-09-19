From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] tcp: simpler bic default
Date: Tue, 19 Sep 2006 14:32:09 -0700
Message-ID: <20060919143209.1164d803@localhost.localdomain>
References: <20060918214104.3824a2e2@localhost.localdomain>
	<20060919.123352.124082859.davem@davemloft.net>
	<20060919134132.44d4da5d@localhost.localdomain>
	<20060919.142007.06541289.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bert.hubert@netherlabs.nl, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:28850 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1752084AbWISVcR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 17:32:17 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060919.142007.06541289.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

New tcp default config
means we can eliminate the hack
that was used previous

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- net-2.6.19.orig/net/ipv4/Kconfig	2006-09-19 14:27:58.000000000 -0700
+++ net-2.6.19/net/ipv4/Kconfig	2006-09-19 14:28:17.000000000 -0700
@@ -602,10 +602,6 @@
 
 endmenu
 
-config DEFAULT_BIC
-	depends on !TCP_CONG_ADVANCED
-	default y
-
 config DEFAULT_TCP_CONG
 	string
 	default "bic" if DEFAULT_BIC
@@ -614,6 +610,7 @@
 	default "vegas" if DEFAULT_VEGAS
 	default "westwood" if DEFAULT_WESTWOOD
 	default "reno" if DEFAULT_RENO
+	default "bic"
 
 source "net/ipv4/ipvs/Kconfig"
 
