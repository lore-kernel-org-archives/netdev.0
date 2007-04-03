From: John Heffner <jheffner@psc.edu>
Subject: [PATCH] [iputils] Add documentation for the -l flag.
Date: Tue,  3 Apr 2007 13:51:07 -0400
Message-ID: <11756226682486-git-send-email-jheffner@psc.edu>
References: <460474E1.9070805@psc.edu>
Cc: netdev@vger.kernel.org, John Heffner <jheffner@psc.edu>
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:60697 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161115AbXDCSfs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2007 14:35:48 -0400
In-Reply-To: <460474E1.9070805@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

---
 doc/tracepath.sgml |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/doc/tracepath.sgml b/doc/tracepath.sgml
index 71eaa8d..c0f308b 100644
--- a/doc/tracepath.sgml
+++ b/doc/tracepath.sgml
@@ -15,6 +15,7 @@ traces path to a network host discovering MTU along this path</refpurpose>
 <refsynopsisdiv>
 <cmdsynopsis>
 <command>tracepath</command>
+<arg choice="opt">-l <replaceable/pktlen/</arg>
 <arg choice="req"><replaceable/destination/</arg>
 <arg choice="opt"><replaceable/port/</arg>
 </cmdsynopsis>
@@ -39,6 +40,18 @@ of UDP ports to maintain trace history.
 </para>
 </refsect1>
 
+<refsect1><title>OPTIONS</title>
+<variablelist>
+ <varlistentry>
+  <term><option/-l/</term>
+  <listitem><para>
+Sets the initial packet length to <replaceable/pktlen/ instead of
+65536 for <command/tracepath/ or 128000 for <command/tracepath6/.
+  </para></listitem>
+ </varlistentry>
+</variablelist>
+</refsect1>
+
 <refsect1><title>OUTPUT</title>
 <para>
 <literallayout>
-- 
1.5.0.2.gc260-dirty

