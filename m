From: Christian Tschudin <Christian.Tschudin@unibas.ch>
Subject: PROBLEM: nd_tbl not a public symbol in net/ipv6/ndisc.c
Date: Mon, 31 Jan 2005 09:04:34 +0100 (MET)
Message-ID: <Pine.OSF.4.58.0501310903220.211@igor.urz.unibas.ch>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Our LUNAR project (underlay for wireless multihop networks)
stumbled over the same problem that at least two other projects
(infiniband, and mipv6) also experienced many months ago:

  The neighbor table 'nd_tbl' in net/ipv6/ndisc.c
  is not accessible from other modules.

  This prevents several 2.6.x kernel modules in networking
  from being deployed without kernel patching and recompilation.

Please find a patch below.

best, christian tschudin.

---

--- linux-2.6.10/net/ipv6/ipv6_syms.c   2004-12-24 22:35:23.000000000 +0100
+++ work/linux-2.6.10/net/ipv6/ipv6_syms.c      2005-01-30 23:44:42.743620264 +0100
@@ -41,3 +41,4 @@
 EXPORT_SYMBOL(rt6_lookup);
 EXPORT_SYMBOL(fl6_sock_lookup);
 EXPORT_SYMBOL(ipv6_push_nfrag_opts);
+EXPORT_SYMBOL(nd_tbl);

---
Christian Tschudin, University of Basel       http://cn.cs.unibas.ch/
Computer Science Dept, Bernoullistr. 16, CH - 4056 Basel, Switzerland
