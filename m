From: Andreas Schwab <schwab@linux-m68k.org>
Subject: [PATCH] iproute2: Fix various manpage formatting nits
Date: Thu, 06 Sep 2012 15:09:58 +0200
Message-ID: <m2txvbjo0p.fsf@igel.home>
Mime-Version: 1.0
Content-Type: text/plain
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:39439 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754152Ab2IFNKD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 09:10:03 -0400
Received: from frontend1.mail.m-online.net (frontend1.mail.intern.m-online.net [192.168.8.180])
	by mail-out.m-online.net (Postfix) with ESMTP id 3XCMZc6Xvxz3hhXT
	for <netdev@vger.kernel.org>; Thu,  6 Sep 2012 15:10:00 +0200 (CEST)
Received: from igel.home (ppp-93-104-154-231.dynamic.mnet-online.de [93.104.154.231])
	by mail.mnet-online.de (Postfix) with ESMTPA id 3XCMZc28p2zbbfw
	for <netdev@vger.kernel.org>; Thu,  6 Sep 2012 15:10:00 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Andreas Schwab <schwab@linux-m68k.org>
---
 man/man8/ip-route.8.in | 10 +++++-----
 man/man8/ip.8          |  4 ++--
 man/man8/ss.8          |  2 +-
 man/man8/tc-choke.8    |  8 ++++----
 man/man8/tc-drr.8      |  1 +
 man/man8/tc-ematch.8   | 25 +++++++++++--------------
 6 files changed, 24 insertions(+), 26 deletions(-)

diff --git a/man/man8/ip-route.8.in b/man/man8/ip-route.8.in
index 0ca6107..f06fcba 100644
--- a/man/man8/ip-route.8.in
+++ b/man/man8/ip-route.8.in
@@ -202,11 +202,10 @@ error.
 are considered to be dummy (or external) addresses which require translation
 to real (or internal) ones before forwarding.  The addresses to translate to
 are selected with the attribute
+.BR "via" .
 .B Warning:
 Route NAT is no longer supported in Linux 2.6.
 
-
-.BR "via" .
 .sp
 .B anycast
 .RI "- " "not implemented"
@@ -306,7 +305,7 @@ If this parameter is omitted,
 assumes the
 .B main
 table, with the exception of
-.BR local " , " broadcast " and " nat
+.BR local ", " broadcast " and " nat
 routes, which are put into the
 .B local
 table by default.
@@ -560,13 +559,14 @@ i.e. it lists the entire table.
 
 .TP
 .BI tos " TOS"
+.TP
 .BI dsfield " TOS"
 only select routes with the given TOS.
 
 .TP
 .BI table " TABLEID"
-show the routes from this table(s).  The default setting is to show
-.BR table main "."
+show the routes from this table(s).  The default setting is to show table
+.BR main "."
 .I TABLEID
 may either be the ID of a real table or one of the special values:
 .sp
diff --git a/man/man8/ip.8 b/man/man8/ip.8
index 9ba3621..ac78c29 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -85,11 +85,11 @@ shortcut for
 .BR "\-o" , " \-oneline"
 output each record on a single line, replacing line feeds
 with the
-.B '\e\'
+.B '\e'
 character. This is convenient when you want to count records
 with
 .BR wc (1)
- or to
+or to
 .BR grep (1)
 the output.
 
diff --git a/man/man8/ss.8 b/man/man8/ss.8
index 0b9a8c4..f03c6d8 100644
--- a/man/man8/ss.8
+++ b/man/man8/ss.8
@@ -14,7 +14,7 @@ It can display more TCP and state informations than other tools.
 .SH OPTIONS
 When no option is used ss displays a list of 
 open non-listening TCP sockets that have established connection.
-.TP
+.P
 These programs follow the usual GNU command line syntax, with long
 options starting with two dashes (`-').
 A summary of options is included below.
diff --git a/man/man8/tc-choke.8 b/man/man8/tc-choke.8
index 620c7f6..9d1081f 100644
--- a/man/man8/tc-choke.8
+++ b/man/man8/tc-choke.8
@@ -30,11 +30,11 @@ queue.  If both the to-be-queued and the drawn packet belong to the same flow,
 both packets are dropped.  Otherwise, if the queue length is still below the maximum length,
 the new packet has a configurable chance of being marked (which may mean dropped).
 If the queue length exceeds
-.B max
-, the new packet will always be marked (or dropped).
+.BR max ,
+the new packet will always be marked (or dropped).
 If the queue length exceeds
-.B limit
-, the new packet is always dropped.
+.BR limit ,
+the new packet is always dropped.
 
 The marking probability computation is the same as used by the RED qdisc.
 
diff --git a/man/man8/tc-drr.8 b/man/man8/tc-drr.8
index e25d6dd..29daed8 100644
--- a/man/man8/tc-drr.8
+++ b/man/man8/tc-drr.8
@@ -45,6 +45,7 @@ To attach to device eth0, using the interface MTU as its quantum:
 Adding two classes:
 .P
 # tc class add dev eth0 parent 1: classid 1:1 drr
+.br
 # tc class add dev eth0 parent 1: classid 1:2 drr
 .P
 You also need to add at least one filter to classify packets.
diff --git a/man/man8/tc-ematch.8 b/man/man8/tc-ematch.8
index 53ae161..2eafc29 100644
--- a/man/man8/tc-ematch.8
+++ b/man/man8/tc-ematch.8
@@ -21,7 +21,7 @@ ematch \- extended matches for use with "basic" or "flow" filters
 ]
 
 .ti -8
-.IR TERM " := [ " not " ] { " MATCH " | '(' " EXPR " ')' } "
+.IR TERM " := [ " \fBnot " ] { " MATCH " | '(' " EXPR " ')' } "
 
 .ti -8
 .IR MATCH " := " module " '(' " ARGS " ')' "
@@ -34,30 +34,27 @@ ematch \- extended matches for use with "basic" or "flow" filters
 .SS cmp
 Simple comparison ematch: arithmetic compare of packet data to a given value.
 .ti
-.IR cmp "( " ALIGN " at " OFFSET " [ " ATTRS " ]  { " eq " | " lt " | " gt "  } " VALUE " )
+.IR cmp "( " ALIGN " at " OFFSET " [ " ATTRS " ] { " eq " | " lt " | " gt " } " VALUE " )
 
 .ti
 .IR ALIGN " := { " u8 " | " u16 " | " u32 " } "
 
 .ti
-.IR ATTRS " := [  layer " LAYER " ] [ mask " MASK " ] [ " trans " ] "
+.IR ATTRS " := [ layer " LAYER " ] [ mask " MASK " ] [ trans ]
 
 .ti
-.IR ALIGN " := { " u8 " | " u16 " | " u32 } "
-
-.ti
-.IR LAYER " := { " link " | " network " | " transport " | " 0..%d " }
+.IR LAYER " := { " link " | " network " | " transport " | " 0..2 " }
 
 .SS meta
 Metadata ematch
 .ti
-.IR meta "( " OBJECT " { " eq " | " lt "  |" gt " } " OBJECT " )
+.IR meta "( " OBJECT " { " eq " | " lt " |" gt " } " OBJECT " )
 
 .ti
 .IR OBJECT " := { " META_ID " |  " VALUE " }
 
 .ti
-.IR META_ID " := id " [ shift " SHIFT " ] [ mask " MASK " ]
+.IR META_ID " := " id " [ shift " SHIFT " ] [ mask " MASK " ]
 
 .TP
 meta attributes:
@@ -91,26 +88,26 @@ match packet data byte sequence
 .IR OFFSET  " := " int
 
 .ti
-.IR LAYER " := { " link " | " network " | " transport " | " 0..%d " }
+.IR LAYER " := { " link " | " network " | " transport " | " 0..2 " }
 
 .SS u32
 u32 ematch
 .ti
-.IR u32 "( " ALIGN VALUE MASK " at " [ nexthdr+ ] " OFFSET " )
+.IR u32 "( " ALIGN " " VALUE " " MASK " at [ nexthdr+ ] " OFFSET " )
 
 .ti
-.IR ALIGN " := " { " u8 " | " u16 " | " u32 " }
+.IR ALIGN " := { " u8 " | " u16 " | " u32 " }
 
 .SS ipset
 test packet agains ipset membership
 .ti
-.IR ipset "( " SETNAME FLAGS )
+.IR ipset "( " SETNAME " " FLAGS " )
 
 .ti
 .IR SETNAME " := " string
 
 .ti
-.IR FLAGS " := " { " FLAG " [, " FLAGS "] }
+.IR FLAGS " := { " FLAG " [, " FLAGS "] }
 
 The flag options are the same as those used by the iptables "set" match.
 
-- 
1.7.12


-- 
Andreas Schwab, schwab@linux-m68k.org
GPG Key fingerprint = 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
