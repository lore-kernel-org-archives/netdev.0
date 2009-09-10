From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 15/31: xtables: realign struct xt_target_param
Date: Thu, 10 Sep 2009 18:12:06 +0200 (MEST)
Message-ID: <20090910161201.31179.42927.sendpatchset@x2.localnet>
References: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64671 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752447AbZIJQMD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2009 12:12:03 -0400
In-Reply-To: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 98d89b4198cf7273968e9217a62ec7ccfd760171
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Sun Jul 5 15:55:06 2009 +0200

    netfilter: xtables: realign struct xt_target_param
    
    This commit gets rid of a padding hole as reported by pahole(1).
    Saves 8 bytes on x86_64.
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 1030b75..4fa6e4c 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -238,9 +238,9 @@ struct xt_mtdtor_param {
  */
 struct xt_target_param {
 	const struct net_device *in, *out;
-	unsigned int hooknum;
 	const struct xt_target *target;
 	const void *targinfo;
+	unsigned int hooknum;
 	u_int8_t family;
 };
 
