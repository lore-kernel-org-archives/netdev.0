From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [PATCH iproute2] ip: replace exit with return
Date: Tue, 11 Aug 2015 09:40:23 +0000
Message-ID: <1439286023-3648-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Cc: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:8322 "EHLO
	cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933396AbbHKJhe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 05:37:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In our manual, we have this description of 'EXIT STATUS':
Exit status is 0 if command was successful, and 1 if there is a syntax
error.

But we exit in command functions with code -1 when there is a syntax error.
It's better to use return.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 ip/ipaddress.c   | 2 +-
 ip/ipaddrlabel.c | 2 +-
 ip/ipfou.c       | 2 +-
 ip/ipl2tp.c      | 2 +-
 ip/iplink.c      | 2 +-
 ip/ipmaddr.c     | 2 +-
 ip/ipmroute.c    | 2 +-
 ip/ipneigh.c     | 2 +-
 ip/ipnetconf.c   | 2 +-
 ip/ipnetns.c     | 2 +-
 ip/ipntable.c    | 2 +-
 ip/iproute.c     | 2 +-
 ip/iprule.c      | 2 +-
 ip/iptoken.c     | 2 +-
 ip/iptunnel.c    | 2 +-
 ip/iptuntap.c    | 2 +-
 ip/ipxfrm.c      | 2 +-
 ip/tcp_metrics.c | 2 +-
 18 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index b7b4e3e..6d29a69 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -1879,5 +1879,5 @@ int do_ipaddr(int argc, char **argv)
 	if (matches(*argv, "help") == 0)
 		usage();
 	fprintf(stderr, "Command \"%s\" is unknown, try \"ip addr help\".\n", *argv);
-	exit(-1);
+	return -1;
 }
diff --git a/ip/ipaddrlabel.c b/ip/ipaddrlabel.c
index a738ded..3c59d99 100644
--- a/ip/ipaddrlabel.c
+++ b/ip/ipaddrlabel.c
@@ -261,6 +261,6 @@ int do_ipaddrlabel(int argc, char **argv)
 		usage();
 
 	fprintf(stderr, "Command \"%s\" is unknown, try \"ip addrlabel help\".\n", *argv);
-	exit(-1);
+	return -1;
 }
 
diff --git a/ip/ipfou.c b/ip/ipfou.c
index 0b83c27..eeb3103 100644
--- a/ip/ipfou.c
+++ b/ip/ipfou.c
@@ -154,6 +154,6 @@ int do_ipfou(int argc, char **argv)
 		usage();
 
 	fprintf(stderr, "Command \"%s\" is unknown, try \"ip fou help\".\n", *argv);
-	exit(-1);
+	return -1;
 }
 
diff --git a/ip/ipl2tp.c b/ip/ipl2tp.c
index 2f7c9bf..8315d3a 100644
--- a/ip/ipl2tp.c
+++ b/ip/ipl2tp.c
@@ -745,5 +745,5 @@ int do_ipl2tp(int argc, char **argv)
 		usage();
 
 	fprintf(stderr, "Command \"%s\" is unknown, try \"ip l2tp help\".\n", *argv);
-	exit(-1);
+	return -1;
 }
diff --git a/ip/iplink.c b/ip/iplink.c
index e296e6f..de5a3c9 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -1219,5 +1219,5 @@ int do_iplink(int argc, char **argv)
 		return ipaddr_list_link(0, NULL);
 
 	fprintf(stderr, "Command \"%s\" is unknown, try \"ip link help\".\n", *argv);
-	exit(-1);
+	return -1;
 }
diff --git a/ip/ipmaddr.c b/ip/ipmaddr.c
index a77a18f..fb85999 100644
--- a/ip/ipmaddr.c
+++ b/ip/ipmaddr.c
@@ -344,5 +344,5 @@ int do_multiaddr(int argc, char **argv)
 	if (matches(*argv, "help") == 0)
 		usage();
 	fprintf(stderr, "Command \"%s\" is unknown, try \"ip maddr help\".\n", *argv);
-	exit(-1);
+	return -1;
 }
diff --git a/ip/ipmroute.c b/ip/ipmroute.c
index fffa9e2..efc9bc0 100644
--- a/ip/ipmroute.c
+++ b/ip/ipmroute.c
@@ -283,5 +283,5 @@ int do_multiroute(int argc, char **argv)
 	if (matches(*argv, "help") == 0)
 		usage();
 	fprintf(stderr, "Command \"%s\" is unknown, try \"ip mroute help\".\n", *argv);
-	exit(-1);
+	return -1;
 }
diff --git a/ip/ipneigh.c b/ip/ipneigh.c
index a9e23f4..e2519b1 100644
--- a/ip/ipneigh.c
+++ b/ip/ipneigh.c
@@ -479,5 +479,5 @@ int do_ipneigh(int argc, char **argv)
 		return do_show_or_flush(0, NULL, 0);
 
 	fprintf(stderr, "Command \"%s\" is unknown, try \"ip neigh help\".\n", *argv);
-	exit(-1);
+	return -1;
 }
diff --git a/ip/ipnetconf.c b/ip/ipnetconf.c
index eca6eee..bc598d8 100644
--- a/ip/ipnetconf.c
+++ b/ip/ipnetconf.c
@@ -210,5 +210,5 @@ int do_ipnetconf(int argc, char **argv)
 		return do_show(0, NULL);
 
 	fprintf(stderr, "Command \"%s\" is unknown, try \"ip netconf help\".\n", *argv);
-	exit(-1);
+	return -1;
 }
diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index 3b704a4..89856d4 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -810,5 +810,5 @@ int do_netns(int argc, char **argv)
 		return netns_monitor(argc-1, argv+1);
 
 	fprintf(stderr, "Command \"%s\" is unknown, try \"ip netns help\".\n", *argv);
-	exit(-1);
+	return -1;
 }
diff --git a/ip/ipntable.c b/ip/ipntable.c
index 5e84b95..b6fc09f 100644
--- a/ip/ipntable.c
+++ b/ip/ipntable.c
@@ -663,5 +663,5 @@ int do_ipntable(int argc, char **argv)
 		return ipntable_show(0, NULL);
 
 	fprintf(stderr, "Command \"%s\" is unknown, try \"ip ntable help\".\n", *argv);
-	exit(-1);
+	return -1;
 }
diff --git a/ip/iproute.c b/ip/iproute.c
index 8f49e62..366161b 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -1805,6 +1805,6 @@ int do_iproute(int argc, char **argv)
 	if (matches(*argv, "help") == 0)
 		usage();
 	fprintf(stderr, "Command \"%s\" is unknown, try \"ip route help\".\n", *argv);
-	exit(-1);
+	return -1;
 }
 
diff --git a/ip/iprule.c b/ip/iprule.c
index 714278a..f4aae59 100644
--- a/ip/iprule.c
+++ b/ip/iprule.c
@@ -459,7 +459,7 @@ int do_iprule(int argc, char **argv)
 		usage();
 
 	fprintf(stderr, "Command \"%s\" is unknown, try \"ip rule help\".\n", *argv);
-	exit(-1);
+	return -1;
 }
 
 int do_multirule(int argc, char **argv)
diff --git a/ip/iptoken.c b/ip/iptoken.c
index a38194c..3e3c65c 100644
--- a/ip/iptoken.c
+++ b/ip/iptoken.c
@@ -207,5 +207,5 @@ int do_iptoken(int argc, char **argv)
 		usage();
 
 	fprintf(stderr, "Command \"%s\" is unknown, try \"ip token help\".\n", *argv);
-	exit(-1);
+	return -1;
 }
diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index 78fa988..1552902 100644
--- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -670,5 +670,5 @@ int do_iptunnel(int argc, char **argv)
 		return do_show(0, NULL);
 
 	fprintf(stderr, "Command \"%s\" is unknown, try \"ip tunnel help\"\n", *argv);
-	exit(-1);
+	return -1;
 }
diff --git a/ip/iptuntap.c b/ip/iptuntap.c
index b9b28a1..302a36b 100644
--- a/ip/iptuntap.c
+++ b/ip/iptuntap.c
@@ -323,5 +323,5 @@ int do_iptuntap(int argc, char **argv)
 
 	fprintf(stderr, "Command \"%s\" is unknown, try \"ip tuntap help\".\n",
 		*argv);
-	exit(-1);
+	return -1;
 }
diff --git a/ip/ipxfrm.c b/ip/ipxfrm.c
index e583abf..e27a3f7 100644
--- a/ip/ipxfrm.c
+++ b/ip/ipxfrm.c
@@ -1532,7 +1532,7 @@ int do_xfrm(int argc, char **argv)
 	else if (matches(*argv, "help") == 0) {
 		usage();
 		fprintf(stderr, "xfrm Object \"%s\" is unknown.\n", *argv);
-		exit(-1);
+		return -1;
 	}
 	usage();
 }
diff --git a/ip/tcp_metrics.c b/ip/tcp_metrics.c
index bdc503e..fcb9efe 100644
--- a/ip/tcp_metrics.c
+++ b/ip/tcp_metrics.c
@@ -506,6 +506,6 @@ int do_tcp_metrics(int argc, char **argv)
 
 	fprintf(stderr, "Command \"%s\" is unknown, "
 			"try \"ip tcp_metrics help\".\n", *argv);
-	exit(-1);
+	return -1;
 }
 
-- 
1.8.3.1
