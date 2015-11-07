From: =?UTF-8?q?Ville=20Skytt=C3=A4?= <ville.skytta@iki.fi>
Subject: [PATCH 1/2] man: Syntax and warning fixes
Date: Sat,  7 Nov 2015 11:52:59 +0200
Message-ID: <1446889980-23970-1-git-send-email-ville.skytta@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f48.google.com ([209.85.215.48]:34135 "EHLO
	mail-lf0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752483AbbKGJxE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Nov 2015 04:53:04 -0500
Received: by lfgh9 with SMTP id h9so81415946lfg.1
        for <netdev@vger.kernel.org>; Sat, 07 Nov 2015 01:53:02 -0800 (PST)
Received: from viper.bobcat.mine.nu (62-78-200-229.bb.dnainternet.fi. [62.78.200.229])
        by smtp.gmail.com with ESMTPSA id f138sm718320lfd.6.2015.11.07.01.53.01
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 07 Nov 2015 01:53:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ix syntax issues and warnings highlighted by `man --warnings=3Dw' fr=
om
man-db 2.7.1.

Signed-off-by: Ville Skytt=C3=A4 <ville.skytta@iki.fi>
---
 man/man8/tc-bpf.8         | 2 +-
 man/man8/tipc-bearer.8    | 4 ++--
 man/man8/tipc-link.8      | 6 +++---
 man/man8/tipc-media.8     | 4 ++--
 man/man8/tipc-nametable.8 | 4 ++--
 man/man8/tipc-node.8      | 4 ++--
 man/man8/tipc-socket.8    | 4 ++--
 7 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/man/man8/tc-bpf.8 b/man/man8/tc-bpf.8
index 2c02ab2..f5201d3 100644
--- a/man/man8/tc-bpf.8
+++ b/man/man8/tc-bpf.8
@@ -844,7 +844,7 @@ result in the default classid:
 Basically, such a minimal generator is equivalent to:
=20
 .in +4n
-.B tcpdump -iem1 -ddd 'tcp[tcpflags] & tcp-syn !=3D 0' | tr '\\n' ',' =
> /var/bpf/tcp-syn
+.B tcpdump -iem1 -ddd 'tcp[tcpflags] & tcp-syn !=3D 0' | tr '\\\\n' ',=
' > /var/bpf/tcp-syn
 .in
=20
 Since
diff --git a/man/man8/tipc-bearer.8 b/man/man8/tipc-bearer.8
index f59c39d..50a1ed2 100644
--- a/man/man8/tipc-bearer.8
+++ b/man/man8/tipc-bearer.8
@@ -1,7 +1,7 @@
 .TH TIPC-BEARER 8 "02 Jun 2015" "iproute2" "Linux"
=20
-./ For consistency, please keep padding right aligned.
-./ For example '.B "foo " bar' and not '.B foo " bar"'
+.\" For consistency, please keep padding right aligned.
+.\" For example '.B "foo " bar' and not '.B foo " bar"'
=20
 .SH NAME
 tipc-bearer \- show or modify TIPC bearers
diff --git a/man/man8/tipc-link.8 b/man/man8/tipc-link.8
index 899b882..3be8c9a 100644
--- a/man/man8/tipc-link.8
+++ b/man/man8/tipc-link.8
@@ -1,7 +1,7 @@
 .TH TIPC-LINK 8 "02 Jun 2015" "iproute2" "Linux"
=20
-./ For consistency, please keep padding right aligned.
-./ For example '.B "foo " bar' and not '.B foo " bar"'
+.\" For consistency, please keep padding right aligned.
+.\" For example '.B "foo " bar' and not '.B foo " bar"'
=20
 .SH NAME
 tipc-link \- show links or modify link properties
@@ -33,7 +33,7 @@ tipc-link \- show links or modify link properties
 .I LINK
 .RB "] | " "reset
 .BI "link " "LINK "
-.R }
+}
=20
 .ti -8
 .B tipc link list
diff --git a/man/man8/tipc-media.8 b/man/man8/tipc-media.8
index 7f94efe..6c6e2b1 100644
--- a/man/man8/tipc-media.8
+++ b/man/man8/tipc-media.8
@@ -1,7 +1,7 @@
 .TH TIPC-MEDIA 8 "02 Jun 2015" "iproute2" "Linux"
=20
-./ For consistency, please keep padding right aligned.
-./ For example '.B "foo " bar' and not '.B foo " bar"'
+.\" For consistency, please keep padding right aligned.
+.\" For example '.B "foo " bar' and not '.B foo " bar"'
=20
 .SH NAME
 tipc-media \- list or modify media properties
diff --git a/man/man8/tipc-nametable.8 b/man/man8/tipc-nametable.8
index c8d573f..d3397f9 100644
--- a/man/man8/tipc-nametable.8
+++ b/man/man8/tipc-nametable.8
@@ -1,7 +1,7 @@
 .TH TIPC-NAMETABLE 8 "02 Jun 2015" "iproute2" "Linux"
=20
-./ For consistency, please keep padding right aligned.
-./ For example '.B "foo " bar' and not '.B foo " bar"'
+.\" For consistency, please keep padding right aligned.
+.\" For example '.B "foo " bar' and not '.B foo " bar"'
=20
 .SH NAME
 tipc-nametable \- show TIPC nametable
diff --git a/man/man8/tipc-node.8 b/man/man8/tipc-node.8
index 66418b3..ef32ec7 100644
--- a/man/man8/tipc-node.8
+++ b/man/man8/tipc-node.8
@@ -1,7 +1,7 @@
 .TH TIPC-NODE 8 "02 Jun 2015" "iproute2" "Linux"
=20
-./ For consistency, please keep padding right aligned.
-./ For example '.B "foo " bar' and not '.B foo " bar"'
+.\" For consistency, please keep padding right aligned.
+.\" For example '.B "foo " bar' and not '.B foo " bar"'
=20
 .SH NAME
 tipc-node \- modify and show local node parameters or list peer nodes
diff --git a/man/man8/tipc-socket.8 b/man/man8/tipc-socket.8
index af18e35..23ec1e5 100644
--- a/man/man8/tipc-socket.8
+++ b/man/man8/tipc-socket.8
@@ -1,7 +1,7 @@
 .TH TIPC-SOCKET 8 "02 Jun 2015" "iproute2" "Linux"
=20
-./ For consistency, please keep padding right aligned.
-./ For example '.B "foo " bar' and not '.B foo " bar"'
+.\" For consistency, please keep padding right aligned.
+.\" For example '.B "foo " bar' and not '.B foo " bar"'
=20
 .SH NAME
 tipc-socket \- show TIPC socket (port) information
--=20
2.4.3
