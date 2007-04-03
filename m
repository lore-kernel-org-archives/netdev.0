From: John Heffner <jheffner@psc.edu>
Subject: [PATCH] [iputils] Document -n flag.
Date: Tue,  3 Apr 2007 13:51:08 -0400
Message-ID: <11756226691331-git-send-email-jheffner@psc.edu>
References: <460474E1.9070805@psc.edu> <11756226682486-git-send-email-jheffner@psc.edu>
Cc: netdev@vger.kernel.org, John Heffner <jheffner@psc.edu>
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:60695 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161114AbXDCSfs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2007 14:35:48 -0400
In-Reply-To: <11756226682486-git-send-email-jheffner@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

---
 doc/tracepath.sgml |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/doc/tracepath.sgml b/doc/tracepath.sgml
index c0f308b..1bc83b9 100644
--- a/doc/tracepath.sgml
+++ b/doc/tracepath.sgml
@@ -15,6 +15,7 @@ traces path to a network host discovering MTU along this path</refpurpose>
 <refsynopsisdiv>
 <cmdsynopsis>
 <command>tracepath</command>
+<arg choice="opt">-n</arg>
 <arg choice="opt">-l <replaceable/pktlen/</arg>
 <arg choice="req"><replaceable/destination/</arg>
 <arg choice="opt"><replaceable/port/</arg>
@@ -42,6 +43,14 @@ of UDP ports to maintain trace history.
 
 <refsect1><title>OPTIONS</title>
 <variablelist>
+
+ <varlistentry>
+  <term><option/-n/</term>
+  <listitem><para>
+Do not look up host names.  Only print IP addresses numerically.
+  </para></listitem>
+ </varlistentry>
+
  <varlistentry>
   <term><option/-l/</term>
   <listitem><para>
-- 
1.5.0.2.gc260-dirty

