From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH 01/12] Fix various typos and nitpicks
Date: Fri, 12 Oct 2007 10:56:36 +0200
Message-ID: <1192179407-22461-1-git-send-email-andreas@fatal.se>
Cc: netdev@vger.kernel.org, Alexander Wirt <formorer@debian.org>,
	Andreas Henriksson <andreas@fatal.se>
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-1-9a.ghn.gbg.bostream.se ([82.182.69.4]:38414 "EHLO
	scream.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755986AbXJLI5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 04:57:52 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Wirt <formorer@debian.org>

Fix typo in ss manpage.
Make the backslash visible in ip manpage (http://bugs.debian.org/285507).
Strict syntax for ip addr advice in error message.
Fix typo in libnetlink(3) manpage (writen -> written).
Fix typos in tc-prio(8) manpage.
Fix typo in tc-htb(8) manpage (mininum -> minimum).
Fix typo in tc-cbq-details(8) manpage (occured -> occurred).

Signed-off-by: Andreas Henriksson <andreas@fatal.se>
---
 ip/ipaddress.c            |    2 +-
 man/man3/libnetlink.3     |    2 +-
 man/man8/ip.8             |    2 +-
 man/man8/ss.8             |    2 +-
 man/man8/tc-cbq-details.8 |    2 +-
 man/man8/tc-htb.8         |    2 +-
 man/man8/tc-prio.8        |    8 ++++----
 7 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 518d8cd..d1c6620 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -1019,7 +1019,7 @@ int do_ipaddr(int argc, char **argv)
 		return ipaddr_list_or_flush(argc-1, argv+1, 1);
 	if (matches(*argv, "help") == 0)
 		usage();
-	fprintf(stderr, "Command \"%s\" is unknown, try \"ip address help\".\n", *argv);
+	fprintf(stderr, "Command \"%s\" is unknown, try \"ip addr help\".\n", *argv);
 	exit(-1);
 }
 
diff --git a/man/man3/libnetlink.3 b/man/man3/libnetlink.3
index 145f38d..15a478a 100644
--- a/man/man3/libnetlink.3
+++ b/man/man3/libnetlink.3
@@ -187,7 +187,7 @@ The functions sometimes use fprintf and exit when a fatal error occurs.
 This library should be named librtnetlink.
 
 .SH AUTHORS
-netlink/rtnetlink was designed and writen by Alexey Kuznetsov.
+netlink/rtnetlink was designed and written by Alexey Kuznetsov.
 Andi Kleen wrote the man page.
 
 .SH SEE ALSO
diff --git a/man/man8/ip.8 b/man/man8/ip.8
index 7181054..153123a 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -379,7 +379,7 @@ shortcut for
 .BR "\-o" , " \-oneline"
 output each record on a single line, replacing line feeds
 with the
-.B '\'
+.B '\e\'
 character. This is convenient when you want to count records 
 with
 .BR wc (1)
diff --git a/man/man8/ss.8 b/man/man8/ss.8
index f732319..19f341e 100644
--- a/man/man8/ss.8
+++ b/man/man8/ss.8
@@ -9,7 +9,7 @@ ss \- another utility to investigate sockets
 is used to dump socket statistics. It allows showing information similar
 to
 .IR netstat .
-It can display more TCP information than state than other tools.
+It can display more TCP and state informations than other tools.
 
 .SH OPTIONS
 These programs follow the usual GNU command line syntax, with long
diff --git a/man/man8/tc-cbq-details.8 b/man/man8/tc-cbq-details.8
index e47da62..09badb9 100644
--- a/man/man8/tc-cbq-details.8
+++ b/man/man8/tc-cbq-details.8
@@ -210,7 +210,7 @@ Consult the map for a class for the
 priority. If found, choose it, and terminate.
 .TP
 (iii)
-Choose the class at which break out to the fallback algorithm occured. Terminate.
+Choose the class at which break out to the fallback algorithm occurred. Terminate.
 .P
 The packet is enqueued to the class which was chosen when either algorithm 
 terminated. It is therefore possible for a packet to be enqueued *not* at a
diff --git a/man/man8/tc-htb.8 b/man/man8/tc-htb.8
index f61b818..d196ecd 100644
--- a/man/man8/tc-htb.8
+++ b/man/man8/tc-htb.8
@@ -137,7 +137,7 @@ packet. Should be at least as high as the highest cburst of all children.
 .SH NOTES
 Due to Unix timing constraints, the maximum ceil rate is not infinite and may in fact be quite low. On Intel, 
 there are 100 timer events per second, the maximum rate is that rate at which 'burst' bytes are sent each timer tick.
-From this, the mininum burst size for a specified rate can be calculated. For i386, a 10mbit rate requires a 12 kilobyte 
+From this, the minimum burst size for a specified rate can be calculated. For i386, a 10mbit rate requires a 12 kilobyte 
 burst as 100*12kb*8 equals 10mbit.
 
 .SH SEE ALSO
diff --git a/man/man8/tc-prio.8 b/man/man8/tc-prio.8
index e942e62..780bcd5 100644
--- a/man/man8/tc-prio.8
+++ b/man/man8/tc-prio.8
@@ -30,7 +30,7 @@ traffic.
 On creation with 'tc qdisc add', a fixed number of bands is created. Each
 band is a class, although is not possible to add classes with 'tc qdisc
 add', the number of bands to be created must instead be specified on the
-commandline attaching PRIO to its root.
+command line attaching PRIO to its root.
 
 When dequeueing, band 0 is tried first and only if it did not deliver a
 packet does PRIO try band 1, and so onwards. Maximum reliability packets
@@ -88,7 +88,7 @@ this:
 The four TOS bits (the 'TOS field') are defined as:
 
 .nf
-Binary Decimcal  Meaning
+Binary Decimal  Meaning
 -----------------------------------------
 1000   8         Minimize delay (md)
 0100   4         Maximize throughput (mt)
@@ -125,13 +125,13 @@ TOS     Bits  Means                    Linux Priority    Band
 
 The second column contains the value of the relevant
 four TOS bits, followed by their translated meaning. For example, 15 stands
-for a packet wanting Minimal Montetary Cost, Maximum Reliability, Maximum
+for a packet wanting Minimal Monetary Cost, Maximum Reliability, Maximum
 Throughput AND Minimum Delay. 
 
 The fourth column lists the way the Linux kernel interprets the TOS bits, by
 showing to which Priority they are mapped.
 
-The last column shows the result of the default priomap. On the commandline,
+The last column shows the result of the default priomap. On the command line,
 the default priomap looks like this:
 
     1, 2, 2, 2, 1, 2, 0, 0 , 1, 1, 1, 1, 1, 1, 1, 1
-- 
1.5.3.4

