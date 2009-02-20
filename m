From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/2] llc: fix non-const printk warning
Date: Fri, 20 Feb 2009 10:02:06 -0800
Message-ID: <20090220100206.533d59d4@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45514 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753011AbZBTSDJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Feb 2009 13:03:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mark some strings as const.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/llc/af_llc.c	2009-02-20 08:34:21.537870609 -0800
+++ b/net/llc/af_llc.c	2009-02-20 08:37:52.920622312 -0800
@@ -1118,11 +1118,11 @@ static const struct proto_ops llc_ui_ops
 	.sendpage    = sock_no_sendpage,
 };
 
-static char llc_proc_err_msg[] __initdata =
+static const char llc_proc_err_msg[] __initconst =
 	KERN_CRIT "LLC: Unable to register the proc_fs entries\n";
-static char llc_sysctl_err_msg[] __initdata =
+static const char llc_sysctl_err_msg[] __initconst =
 	KERN_CRIT "LLC: Unable to register the sysctl entries\n";
-static char llc_sock_err_msg[] __initdata =
+static const char llc_sock_err_msg[] __initconst =
 	KERN_CRIT "LLC: Unable to register the network family\n";
 
 static int __init llc2_init(void)
