From: Hubert Kario <hkario@redhat.com>
Subject: [PATCH] add short description of batch mode in tc man page
Date: Thu, 11 Apr 2013 10:49:50 -0400 (EDT)
Message-ID: <1849222950.2545903.1365691790107.JavaMail.root@redhat.com>
References: <756691184.2545557.1365691755445.JavaMail.root@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, ahu@ds9a.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4-phx2.redhat.com ([209.132.183.25]:40865 "EHLO
	mx4-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752044Ab3DKOt4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 10:49:56 -0400
In-Reply-To: <756691184.2545557.1365691755445.JavaMail.root@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The tc command is missing documentation of -batch and -force switches
that are returned by "tc -help".
Add short description on their syntax and usage.
---
 man/man8/tc.8 | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/man/man8/tc.8 b/man/man8/tc.8
index bbc6790..e0acfeb 100644
--- a/man/man8/tc.8
+++ b/man/man8/tc.8
@@ -48,6 +48,9 @@ DEV
 .B tc filter show dev
 DEV
=20
+.P
+.B tc [ -force ] -b\fR[\fIatch\fR] \fB[ filename ]
+
 .ti 8
 .IR FORMAT " :=3D {"
 \fB\-s\fR[\fItatistics\fR] |
@@ -427,6 +430,15 @@ decode filter offset and mask values to equivalent=
 filter commands based on TCP/
 .BR "\-iec"
 print rates in IEC units (ie. 1K =3D 1024).
=20
+.TP
+.BR "\-b", " \-b filename", " \-batch", " \-batch filename"
+read commands from provided file or standard input and invoke them.
+First failure will cause termination of tc.
+
+.TP
+.BR "\-force"
+don't terminate tc on errors in batch mode.
+If there were any errors during execution of the commands, the applica=
tion return code will be non zero.
=20
 .SH HISTORY
 .B tc
--=20
1.8.1.4

--=20
Regards,
Hubert Kario
Quality Engineer, QE BaseOS Security team
http://wiki.brq.redhat.com/hkario
Email: hkario@redhat.com
Web: www.cz.redhat.com
Red Hat Czech s.r.o., Purky=C5=88ova 99/71, 612 45, Brno, Czech Republi=
c
