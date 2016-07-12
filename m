From: Davide Caratti <dcaratti@redhat.com>
Subject: [iproute PATCH v2] ip-macsec.8: fix typo in 'examples' section
Date: Tue, 12 Jul 2016 17:28:30 +0200
Message-ID: <77dd47e67a8b89ccbe6e05c608ae9b9f5ce376b4.1468334712.git.dcaratti@redhat.com>
References: <49c1e540558e6b6ea422872e8bd4e8501e07e25a.1468310945.git.dcaratti@redhat.com>
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59888 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751366AbcGLP2w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jul 2016 11:28:52 -0400
In-Reply-To: <49c1e540558e6b6ea422872e8bd4e8501e07e25a.1468310945.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix wrong 'device' keyword in 'ip link add device eth0'

changes since v1:
while at it, add missing description of 'validate' keyword and remove
spurious bracket near 'encrypt' keyword. Also, wrong 'es' and 'encoding'
keywords in MACsec section of ip-link.8 have been fixed.

Signed-off-by: Davide Caratti <dcaratti@redhat.com>
---
 man/man8/ip-link.8.in | 8 ++++----
 man/man8/ip-macsec.8  | 5 +++--
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index ad18f75..edb00ff 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -910,14 +910,14 @@ the following additional arguments are supported:
 .BR encrypt " {"
 .BR on " | " off " } ] [ "
 .BR send_sci " { " on " | " off " } ] ["
-.BR es " { " on " | " off " } ] ["
+.BR end_station " { " on " | " off " } ] ["
 .BR scb " { " on " | " off " } ] ["
 .BR protect " { " on " | " off " } ] ["
 .BR replay " { " on " | " off " }"
 .BR window " { "
 .IR 0..2^32-1 " } ] ["
 .BR validate " { " strict " | " check " | " disabled " } ] ["
-.BR encoding " { "
+.BR encodingsa " { "
 .IR 0..3 " } ]"
 
 .in +8
@@ -942,7 +942,7 @@ the following additional arguments are supported:
 - specifies whether the SCI is included in every packet, or only when it is necessary.
 
 .sp
-.BR "es on " or " es off"
+.BR "end_station on " or " end_station off"
 - sets the End Station bit.
 
 .sp
@@ -970,7 +970,7 @@ the following additional arguments are supported:
 - sets the validation mode on the device.
 
 .sp
-.BI encoding " AN "
+.BI encodingsa " AN "
 - sets the active secure association for transmission.
 
 .in -8
diff --git a/man/man8/ip-macsec.8 b/man/man8/ip-macsec.8
index e8455d7..761e4de 100644
--- a/man/man8/ip-macsec.8
+++ b/man/man8/ip-macsec.8
@@ -6,7 +6,7 @@ ip-macsec \- MACsec device configuration
 [ [
 .BR cipher " { " default " | " gcm-aes-128 " } ] "
 .BI icvlen " ICVLEN"
-] [ [
+] [
 .BR encrypt " { " on " | " off " } ] ["
 .BR send_sci " { " on " | " off " } ] ["
 .BR end_station " { " on " | " off " } ] ["
@@ -15,6 +15,7 @@ ip-macsec \- MACsec device configuration
 .BR replay " { " on " | " off " } ] ["
 .BI window " WINDOW"
 ] [
+.BR validate " { " strict " | " check " | " disabled " } ] ["
 .BI encodingsa " SA"
 ]
 
@@ -74,7 +75,7 @@ type.
 .PP
 .SS Create a MACsec device on link eth0
 .nf
-# ip link add device eth0 macsec0 type macsec port 11 encrypt on
+# ip link add link eth0 macsec0 type macsec port 11 encrypt on
 .PP
 .SS Configure a secure association on that device
 .nf
-- 
2.5.5
