From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/5] netfilter: add my copyright statements
Date: Fri, 19 Apr 2013 03:27:35 +0200
Message-ID: <1366334855-5261-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57388 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967266Ab3DSB1r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 21:27:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Add copyright statements to all netfilter files which have had significant
changes done by myself in the past.

Some notes:

- nf_conntrack_ecache.c was incorrectly attributed to Rusty and Netfilter
  Core Team when it got split out of nf_conntrack_core.c. The copyrights
  even state a date which lies six years before it was written. It was
  written in 2005 by Harald and myself.

- net/ipv{4,6}/netfilter.c, net/netfitler/nf_queue.c were missing copyright
  statements. I've added the copyright statement from net/netfilter/core.c,
  where this code originated

- for nf_conntrack_proto_tcp.c I've also added Jozsef, since I didn't want
  it to give the wrong impression

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter.c                                  |    7 ++++++-
 net/ipv4/netfilter/arp_tables.c                       |    1 +
 net/ipv4/netfilter/ip_tables.c                        |    1 +
 net/ipv4/netfilter/ipt_ULOG.c                         |    1 +
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c        |    1 +
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c |    1 +
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c          |    1 +
 net/ipv4/netfilter/nf_nat_h323.c                      |    1 +
 net/ipv4/netfilter/nf_nat_pptp.c                      |    2 ++
 net/ipv4/netfilter/nf_nat_proto_gre.c                 |    2 ++
 net/ipv4/netfilter/nf_nat_snmp_basic.c                |    2 ++
 net/ipv6/netfilter.c                                  |    6 ++++++
 net/ipv6/netfilter/ip6_tables.c                       |    1 +
 net/ipv6/netfilter/ip6t_REJECT.c                      |    2 ++
 net/netfilter/core.c                                  |    1 +
 net/netfilter/nf_conntrack_amanda.c                   |    1 +
 net/netfilter/nf_conntrack_core.c                     |    1 +
 net/netfilter/nf_conntrack_ecache.c                   |    8 +++++---
 net/netfilter/nf_conntrack_expect.c                   |    1 +
 net/netfilter/nf_conntrack_ftp.c                      |    1 +
 net/netfilter/nf_conntrack_h323_main.c                |    1 +
 net/netfilter/nf_conntrack_helper.c                   |    1 +
 net/netfilter/nf_conntrack_irc.c                      |    1 +
 net/netfilter/nf_conntrack_pptp.c                     |    2 ++
 net/netfilter/nf_conntrack_proto.c                    |    1 +
 net/netfilter/nf_conntrack_proto_gre.c                |    1 +
 net/netfilter/nf_conntrack_proto_sctp.c               |    3 +++
 net/netfilter/nf_conntrack_proto_tcp.c                |    2 ++
 net/netfilter/nf_conntrack_proto_udp.c                |    1 +
 net/netfilter/nf_conntrack_standalone.c               |    1 +
 net/netfilter/nf_conntrack_tftp.c                     |    2 +-
 net/netfilter/nf_nat_amanda.c                         |    1 +
 net/netfilter/nf_nat_helper.c                         |    1 +
 net/netfilter/nf_queue.c                              |    5 +++++
 net/netfilter/nfnetlink_log.c                         |    1 +
 net/netfilter/x_tables.c                              |    1 +
 net/netfilter/xt_TCPMSS.c                             |    1 +
 net/netfilter/xt_conntrack.c                          |    1 +
 net/netfilter/xt_hashlimit.c                          |    1 +
 net/netfilter/xt_limit.c                              |    1 +
 40 files changed, 66 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index 8b201e8..c3e0ade 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -1,4 +1,9 @@
-/* IPv4 specific functions of netfilter core */
+/*
+ * IPv4 specific functions of netfilter core
+ *
+ * Rusty Russell (C) 2000 -- This code is GPL.
+ * Patrick McHardy (C) 2006-2012
+ */
 #include <linux/kernel.h>
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv4.h>
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 7dc6a97..85a4f21 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -6,6 +6,7 @@
  * Some ARP specific bits are:
  *
  * Copyright (C) 2002 David S. Miller (davem@redhat.com)
+ * Copyright (C) 2006-2009 Patrick McHardy <kaber@trash.net>
  *
  */
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index e391db1..d23118d 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -3,6 +3,7 @@
  *
  * Copyright (C) 1999 Paul `Rusty' Russell & Michael J. Neuling
  * Copyright (C) 2000-2005 Netfilter Core Team <coreteam@netfilter.org>
+ * Copyright (C) 2006-2010 Patrick McHardy <kaber@trash.net>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
diff --git a/net/ipv4/netfilter/ipt_ULOG.c b/net/ipv4/netfilter/ipt_ULOG.c
index 8799c83..f8a222cb 100644
--- a/net/ipv4/netfilter/ipt_ULOG.c
+++ b/net/ipv4/netfilter/ipt_ULOG.c
@@ -4,6 +4,7 @@
  * (C) 2000-2004 by Harald Welte <laforge@netfilter.org>
  * (C) 1999-2001 Paul `Rusty' Russell
  * (C) 2002-2004 Netfilter Core Team <coreteam@netfilter.org>
+ * (C) 2005-2007 Patrick McHardy <kaber@trash.net>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 2820aa1..567d841 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -1,6 +1,7 @@
 
 /* (C) 1999-2001 Paul `Rusty' Russell
  * (C) 2002-2004 Netfilter Core Team <coreteam@netfilter.org>
+ * (C) 2006-2012 Patrick McHardy <kaber@trash.net>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
index f2ca127..4c48e43 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
@@ -2,6 +2,7 @@
  *
  * (C) 1999-2001 Paul `Rusty' Russell
  * (C) 2002-2006 Netfilter Core Team <coreteam@netfilter.org>
+ * (C) 2006-2010 Patrick McHardy <kaber@trash.net>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
index c2cd63d..a338dad 100644
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -1,5 +1,6 @@
 /* (C) 1999-2001 Paul `Rusty' Russell
  * (C) 2002-2004 Netfilter Core Team <coreteam@netfilter.org>
+ * (C) 2006-2010 Patrick McHardy <kaber@trash.net>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
diff --git a/net/ipv4/netfilter/nf_nat_h323.c b/net/ipv4/netfilter/nf_nat_h323.c
index 9c3db10..9eea059d 100644
--- a/net/ipv4/netfilter/nf_nat_h323.c
+++ b/net/ipv4/netfilter/nf_nat_h323.c
@@ -2,6 +2,7 @@
  * H.323 extension for NAT alteration.
  *
  * Copyright (c) 2006 Jing Min Zhao <zhaojingmin@users.sourceforge.net>
+ * Copyright (c) 2006-2012 Patrick McHardy <kaber@trash.net>
  *
  * This source code is licensed under General Public License version 2.
  *
diff --git a/net/ipv4/netfilter/nf_nat_pptp.c b/net/ipv4/netfilter/nf_nat_pptp.c
index a06d7d7..657d230 100644
--- a/net/ipv4/netfilter/nf_nat_pptp.c
+++ b/net/ipv4/netfilter/nf_nat_pptp.c
@@ -13,6 +13,8 @@
  *
  * Development of this code funded by Astaro AG (http://www.astaro.com/)
  *
+ * (C) 2006-2012 Patrick McHardy <kaber@trash.net>
+ *
  * TODO: - NAT to a unique tuple, not to TCP source port
  * 	   (needs netfilter tuple reservation)
  */
diff --git a/net/ipv4/netfilter/nf_nat_proto_gre.c b/net/ipv4/netfilter/nf_nat_proto_gre.c
index ea44f02..690d8901 100644
--- a/net/ipv4/netfilter/nf_nat_proto_gre.c
+++ b/net/ipv4/netfilter/nf_nat_proto_gre.c
@@ -21,6 +21,8 @@
  *
  * Development of this code funded by Astaro AG (http://www.astaro.com/)
  *
+ * (C) 2006-2012 Patrick McHardy <kaber@trash.net>
+ *
  */
 
 #include <linux/module.h>
diff --git a/net/ipv4/netfilter/nf_nat_snmp_basic.c b/net/ipv4/netfilter/nf_nat_snmp_basic.c
index bac7122..5f011cc 100644
--- a/net/ipv4/netfilter/nf_nat_snmp_basic.c
+++ b/net/ipv4/netfilter/nf_nat_snmp_basic.c
@@ -38,6 +38,8 @@
  * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
  *
  * Author: James Morris <jmorris@intercode.com.au>
+ *
+ * Copyright (c) 2006-2010 Patrick McHardy <kaber@trash.net>
  */
 #include <linux/module.h>
 #include <linux/moduleparam.h>
diff --git a/net/ipv6/netfilter.c b/net/ipv6/netfilter.c
index fc5fbd7..72836f4 100644
--- a/net/ipv6/netfilter.c
+++ b/net/ipv6/netfilter.c
@@ -1,3 +1,9 @@
+/*
+ * IPv6 specific functions of netfilter core
+ *
+ * Rusty Russell (C) 2000 -- This code is GPL.
+ * Patrick McHardy (C) 2006-2012
+ */
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/ipv6.h>
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 8861b1e..44400c2 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -3,6 +3,7 @@
  *
  * Copyright (C) 1999 Paul `Rusty' Russell & Michael J. Neuling
  * Copyright (C) 2000-2005 Netfilter Core Team <coreteam@netfilter.org>
+ * Copyright (c) 2006-2010 Patrick McHardy <kaber@trash.net>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
diff --git a/net/ipv6/netfilter/ip6t_REJECT.c b/net/ipv6/netfilter/ip6t_REJECT.c
index ed3b427..70f9abc 100644
--- a/net/ipv6/netfilter/ip6t_REJECT.c
+++ b/net/ipv6/netfilter/ip6t_REJECT.c
@@ -7,6 +7,8 @@
  * Authors:
  *	Yasuyuki Kozakai	<yasuyuki.kozakai@toshiba.co.jp>
  *
+ * Copyright (c) 2005-2007 Patrick McHardy <kaber@trash.net>
+ *
  * Based on net/ipv4/netfilter/ipt_REJECT.c
  *
  * This program is free software; you can redistribute it and/or
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 7d97302..07c865a 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -5,6 +5,7 @@
  * way.
  *
  * Rusty Russell (C)2000 -- This code is GPL.
+ * Patrick McHardy (c) 2006-2012
  */
 #include <linux/kernel.h>
 #include <linux/netfilter.h>
diff --git a/net/netfilter/nf_conntrack_amanda.c b/net/netfilter/nf_conntrack_amanda.c
index dbdaa11..b8b95f4 100644
--- a/net/netfilter/nf_conntrack_amanda.c
+++ b/net/netfilter/nf_conntrack_amanda.c
@@ -2,6 +2,7 @@
  *
  * (C) 2002 by Brian J. Murrell <netfilter@interlinx.bc.ca>
  * based on HW's ip_conntrack_irc.c as well as other modules
+ * (C) 2006 Patrick McHardy <kaber@trash.net>
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 007e8c4..0cd9cf2 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -5,6 +5,7 @@
 /* (C) 1999-2001 Paul `Rusty' Russell
  * (C) 2002-2006 Netfilter Core Team <coreteam@netfilter.org>
  * (C) 2003,2004 USAGI/WIDE Project <http://www.linux-ipv6.org>
+ * (C) 2005-2012 Patrick McHardy <kaber@trash.net>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
diff --git a/net/netfilter/nf_conntrack_ecache.c b/net/netfilter/nf_conntrack_ecache.c
index b5d2eb8..1df1761 100644
--- a/net/netfilter/nf_conntrack_ecache.c
+++ b/net/netfilter/nf_conntrack_ecache.c
@@ -1,8 +1,10 @@
 /* Event cache for netfilter. */
 
-/* (C) 1999-2001 Paul `Rusty' Russell
- * (C) 2002-2006 Netfilter Core Team <coreteam@netfilter.org>
- * (C) 2003,2004 USAGI/WIDE Project <http://www.linux-ipv6.org>
+/*
+ * (C) 2005 Harald Welte <laforge@gnumonks.org>
+ * (C) 2005 Patrick McHardy <kaber@trash.net>
+ * (C) 2005-2006 Netfilter Core Team <coreteam@netfilter.org>
+ * (C) 2005 USAGI/WIDE Project <http://www.linux-ipv6.org>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index 8c10e3d..7684263 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -3,6 +3,7 @@
 /* (C) 1999-2001 Paul `Rusty' Russell
  * (C) 2002-2006 Netfilter Core Team <coreteam@netfilter.org>
  * (C) 2003,2004 USAGI/WIDE Project <http://www.linux-ipv6.org>
+ * (c) 2005-2012 Patrick McHardy <kaber@trash.net>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
diff --git a/net/netfilter/nf_conntrack_ftp.c b/net/netfilter/nf_conntrack_ftp.c
index 62fb8fa..6b21707 100644
--- a/net/netfilter/nf_conntrack_ftp.c
+++ b/net/netfilter/nf_conntrack_ftp.c
@@ -3,6 +3,7 @@
 /* (C) 1999-2001 Paul `Rusty' Russell
  * (C) 2002-2004 Netfilter Core Team <coreteam@netfilter.org>
  * (C) 2003,2004 USAGI/WIDE Project <http://www.linux-ipv6.org>
+ * (C) 2006-2012 Patrick McHardy <kaber@trash.net>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
index 7df7b36..bdebd03 100644
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -2,6 +2,7 @@
  * H.323 connection tracking helper
  *
  * Copyright (c) 2006 Jing Min Zhao <zhaojingmin@users.sourceforge.net>
+ * Copyright (c) 2006-2012 Patrick McHardy <kaber@trash.net>
  *
  * This source code is licensed under General Public License version 2.
  *
diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index a0b1c5c..974a2a4 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -3,6 +3,7 @@
 /* (C) 1999-2001 Paul `Rusty' Russell
  * (C) 2002-2006 Netfilter Core Team <coreteam@netfilter.org>
  * (C) 2003,2004 USAGI/WIDE Project <http://www.linux-ipv6.org>
+ * (C) 2006-2012 Patrick McHardy <kaber@trash.net>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
diff --git a/net/netfilter/nf_conntrack_irc.c b/net/netfilter/nf_conntrack_irc.c
index 70985c5..0fd2976 100644
--- a/net/netfilter/nf_conntrack_irc.c
+++ b/net/netfilter/nf_conntrack_irc.c
@@ -1,6 +1,7 @@
 /* IRC extension for IP connection tracking, Version 1.21
  * (C) 2000-2002 by Harald Welte <laforge@gnumonks.org>
  * based on RR's ip_conntrack_ftp.c
+ * (C) 2006-2012 Patrick McHardy <kaber@trash.net>
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License
diff --git a/net/netfilter/nf_conntrack_pptp.c b/net/netfilter/nf_conntrack_pptp.c
index e6678d2..7bd03de 100644
--- a/net/netfilter/nf_conntrack_pptp.c
+++ b/net/netfilter/nf_conntrack_pptp.c
@@ -11,6 +11,8 @@
  *
  * Development of this code funded by Astaro AG (http://www.astaro.com/)
  *
+ * (C) 2006-2012 Patrick McHardy <kaber@trash.net>
+ *
  * Limitations:
  * 	 - We blindly assume that control connections are always
  * 	   established in PNS->PAC direction.  This is a violation
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index 58ab405..0ab9636 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -3,6 +3,7 @@
 /* (C) 1999-2001 Paul `Rusty' Russell
  * (C) 2002-2006 Netfilter Core Team <coreteam@netfilter.org>
  * (C) 2003,2004 USAGI/WIDE Project <http://www.linux-ipv6.org>
+ * (C) 2006-2012 Patrick McHardy <kaber@trash.net>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_conntrack_proto_gre.c
index 155ce9f..9d9c0da 100644
--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -21,6 +21,7 @@
  *
  * Development of this code funded by Astaro AG (http://www.astaro.com/)
  *
+ * (C) 2006-2012 Patrick McHardy <kaber@trash.net>
  */
 
 #include <linux/module.h>
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index ec83536..1314d33 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -1,6 +1,9 @@
 /*
  * Connection tracking protocol helper module for SCTP.
  *
+ * Copyright (c) 2004 Kiran Kumar Immidi <immidi_kiran@yahoo.com>
+ * Copyright (c) 2004-2012 Patrick McHardy <kaber@trash.net>
+ *
  * SCTP is defined in RFC 2960. References to various sections in this code
  * are to this RFC.
  *
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index f021a20..4d4d8f1 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -1,5 +1,7 @@
 /* (C) 1999-2001 Paul `Rusty' Russell
  * (C) 2002-2004 Netfilter Core Team <coreteam@netfilter.org>
+ * (C) 2002-2013 Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
+ * (C) 2006-2012 Patrick McHardy <kaber@trash.net>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index fee4322..9d7721c 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -1,5 +1,6 @@
 /* (C) 1999-2001 Paul `Rusty' Russell
  * (C) 2002-2004 Netfilter Core Team <coreteam@netfilter.org>
+ * (C) 2006-2012 Patrick McHardy <kaber@trash.net>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index ebb67d3..bd700b4 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -1,5 +1,6 @@
 /* (C) 1999-2001 Paul `Rusty' Russell
  * (C) 2002-2004 Netfilter Core Team <coreteam@netfilter.org>
+ * (C) 2005-2012 Patrick McHardy <kaber@trash.net>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
diff --git a/net/netfilter/nf_conntrack_tftp.c b/net/netfilter/nf_conntrack_tftp.c
index e9936c8..e68ab4f 100644
--- a/net/netfilter/nf_conntrack_tftp.c
+++ b/net/netfilter/nf_conntrack_tftp.c
@@ -1,5 +1,5 @@
 /* (C) 2001-2002 Magnus Boden <mb@ozaba.mine.nu>
- *
+ * (C) 2006-2012 Patrick McHardy <kaber@trash.net>
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
diff --git a/net/netfilter/nf_nat_amanda.c b/net/netfilter/nf_nat_amanda.c
index 3b67c9d..eb77238 100644
--- a/net/netfilter/nf_nat_amanda.c
+++ b/net/netfilter/nf_nat_amanda.c
@@ -1,6 +1,7 @@
 /* Amanda extension for TCP NAT alteration.
  * (C) 2002 by Brian J. Murrell <netfilter@interlinx.bc.ca>
  * based on a copy of HW's ip_nat_irc.c as well as other modules
+ * (C) 2006-2012 Patrick McHardy <kaber@trash.net>
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License
diff --git a/net/netfilter/nf_nat_helper.c b/net/netfilter/nf_nat_helper.c
index 23c2b38..5fea563 100644
--- a/net/netfilter/nf_nat_helper.c
+++ b/net/netfilter/nf_nat_helper.c
@@ -2,6 +2,7 @@
  *
  * (C) 2000-2002 Harald Welte <laforge@netfilter.org>
  * (C) 2003-2006 Netfilter Core Team <coreteam@netfilter.org>
+ * (C) 2007-2012 Patrick McHardy <kaber@trash.net>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index d812c12..5ccf01e 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -1,3 +1,8 @@
+/*
+ * Rusty Russell (C)2000 -- This code is GPL.
+ * Patrick McHardy (c) 2006-2012
+ */
+
 #include <linux/kernel.h>
 #include <linux/slab.h>
 #include <linux/init.h>
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 1a0be2a..978cea4 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -3,6 +3,7 @@
  * nfetlink.
  *
  * (C) 2005 by Harald Welte <laforge@netfilter.org>
+ * (C) 2006-2012 Patrick McHardy <kaber@trash.net>
  *
  * Based on the old ipv4-only ipt_ULOG.c:
  * (C) 2000-2004 by Harald Welte <laforge@netfilter.org>
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 686c771..1a73b18 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -2,6 +2,7 @@
  * x_tables core - Backend for {ip,ip6,arp}_tables
  *
  * Copyright (C) 2006-2006 Harald Welte <laforge@netfilter.org>
+ * Copyright (C) 2006-2012 Patrick McHardy <kaber@trash.net>
  *
  * Based on existing ip_tables code which is
  *   Copyright (C) 1999 Paul `Rusty' Russell & Michael J. Neuling
diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
index 71a266d..a75240f 100644
--- a/net/netfilter/xt_TCPMSS.c
+++ b/net/netfilter/xt_TCPMSS.c
@@ -2,6 +2,7 @@
  * This is a module which is used for setting the MSS option in TCP packets.
  *
  * Copyright (C) 2000 Marc Boucher <marc@mbsi.ca>
+ * Copyright (C) 2007 Patrick McHardy <kaber@trash.net>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
diff --git a/net/netfilter/xt_conntrack.c b/net/netfilter/xt_conntrack.c
index 61805d7..188404b9 100644
--- a/net/netfilter/xt_conntrack.c
+++ b/net/netfilter/xt_conntrack.c
@@ -3,6 +3,7 @@
  *	information. (Superset of Rusty's minimalistic state match.)
  *
  *	(C) 2001  Marc Boucher (marc@mbsi.ca).
+ *	(C) 2006-2012 Patrick McHardy <kaber@trash.net>
  *	Copyright 
