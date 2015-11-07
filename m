From: =?UTF-8?q?Ville=20Skytt=C3=A4?= <ville.skytta@iki.fi>
Subject: [PATCH 2/2] man: Spelling fixes
Date: Sat,  7 Nov 2015 11:53:00 +0200
Message-ID: <1446889980-23970-2-git-send-email-ville.skytta@iki.fi>
References: <1446889980-23970-1-git-send-email-ville.skytta@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:36177 "EHLO
	mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752509AbbKGJxE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Nov 2015 04:53:04 -0500
Received: by lfs39 with SMTP id 39so51546014lfs.3
        for <netdev@vger.kernel.org>; Sat, 07 Nov 2015 01:53:03 -0800 (PST)
Received: from viper.bobcat.mine.nu (62-78-200-229.bb.dnainternet.fi. [62.78.200.229])
        by smtp.gmail.com with ESMTPSA id f138sm718320lfd.6.2015.11.07.01.53.02
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 07 Nov 2015 01:53:02 -0800 (PST)
In-Reply-To: <1446889980-23970-1-git-send-email-ville.skytta@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ville Skytt=C3=A4 <ville.skytta@iki.fi>
---
 man/man8/bridge.8         | 2 +-
 man/man8/ifcfg.8          | 2 +-
 man/man8/lnstat.8         | 2 +-
 man/man8/tc-bpf.8         | 2 +-
 man/man8/tc-cbq-details.8 | 2 +-
 man/man8/tc-mqprio.8      | 2 +-
 man/man8/tc.8             | 2 +-
 7 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/man/man8/bridge.8 b/man/man8/bridge.8
index 222a438..deccb1c 100644
--- a/man/man8/bridge.8
+++ b/man/man8/bridge.8
@@ -237,7 +237,7 @@ state the port for list for STP BPDUs and drop all =
other traffic.
 .B 2
 - STP LEARNING state. Only valid if STP is enabled on the bridge. In t=
his
 state the port will accept traffic only for the purpose of updating MA=
C
-adress tables.
+address tables.
 .sp
=20
 .B 3
diff --git a/man/man8/ifcfg.8 b/man/man8/ifcfg.8
index 79033bd..1a3786c 100644
--- a/man/man8/ifcfg.8
+++ b/man/man8/ifcfg.8
@@ -1,6 +1,6 @@
 .TH IFCFG 8 "September 24 2009" "iproute2" "Linux"
 .SH NAME
-ifcfg \- simplistic script which replaces ifconfig IP managment
+ifcfg \- simplistic script which replaces ifconfig IP management
 .SH SYNOPSIS
 .ad l
 .in +8
diff --git a/man/man8/lnstat.8 b/man/man8/lnstat.8
index 69fe876..acd5f4a 100644
--- a/man/man8/lnstat.8
+++ b/man/man8/lnstat.8
@@ -172,7 +172,7 @@ Number of dropped conntrack entries to make room fo=
r new ones, if maximum table
 size was reached.
 .sp
 .B icmp_error
-Number of packets wich could not be tracked due to error situation. Th=
is is a
+Number of packets which could not be tracked due to error situation. T=
his is a
 subset of \fBinvalid\fP.
 .sp
 .B expect_new
diff --git a/man/man8/tc-bpf.8 b/man/man8/tc-bpf.8
index f5201d3..c8d5c5f 100644
--- a/man/man8/tc-bpf.8
+++ b/man/man8/tc-bpf.8
@@ -394,7 +394,7 @@ socket, and spawning an application such as
 \&. This approach's advantage is that tc will place the file descripto=
rs
 into the environment and thus make them available just like stdin, std=
out,
 stderr file descriptors, meaning, in case user applications run from w=
ithin
-this fd-owner shell, they can terminate and restart without loosing eB=
PF
+this fd-owner shell, they can terminate and restart without losing eBP=
=46
 maps file descriptors. Example invocation with the previous classifier=
 and
 action mixture:
=20
diff --git a/man/man8/tc-cbq-details.8 b/man/man8/tc-cbq-details.8
index ddaf3ca..86353b5 100644
--- a/man/man8/tc-cbq-details.8
+++ b/man/man8/tc-cbq-details.8
@@ -197,7 +197,7 @@ priority yielded a class, enter the fallback algori=
thm.
 The fallback algorithm resides outside of the loop and is as follows.
 .TP
 (i)
-Consult the defmap of the class at which the jump to fallback occured.=
 If=20
+Consult the defmap of the class at which the jump to fallback occurred=
=2E If=20
 the defmap contains a class for the=20
 .B
 priority
diff --git a/man/man8/tc-mqprio.8 b/man/man8/tc-mqprio.8
index da3bf08..0e1d305 100644
--- a/man/man8/tc-mqprio.8
+++ b/man/man8/tc-mqprio.8
@@ -85,7 +85,7 @@ belong to an application. See kernel and cgroup docum=
entation for details.
 .SH QDISC PARAMETERS
 .TP
 num_tc
-Number of traffic classes to use upto 16 classes supported.
+Number of traffic classes to use. Up to 16 classes supported.
=20
 .TP
 map
diff --git a/man/man8/tc.8 b/man/man8/tc.8
index 700b960..7a1090b 100644
--- a/man/man8/tc.8
+++ b/man/man8/tc.8
@@ -609,7 +609,7 @@ to
=20
 .TP
 .BR "\-cf" , " \-conf " <FILENAME>
-specifies path to the config file. This option is used in conjuction w=
ith other options (e.g.
+specifies path to the config file. This option is used in conjunction =
with other options (e.g.
 .BR -nm ")."
=20
 .SH FORMAT
--=20
2.4.3
