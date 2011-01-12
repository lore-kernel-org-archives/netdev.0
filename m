From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 2/7] ethtool.8: Update date, version, web site
 reference
Date: Wed, 12 Jan 2011 16:22:25 +0000
Message-ID: <1294849345.3946.2.camel@bwh-desktop>
References: <1294849266.3946.0.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:54083 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752640Ab1ALQW1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jan 2011 11:22:27 -0500
In-Reply-To: <1294849266.3946.0.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

diff --git a/ethtool.8 b/ethtool.8
index 1760924..8c2137b 100644
--- a/ethtool.8
+++ b/ethtool.8
@@ -1,6 +1,7 @@
 .\" -*- nroff -*-
 .\" Copyright 1999 by David S. Miller.  All Rights Reserved.
 .\" Portions Copyright 2001 Sun Microsystems
+.\" Portions Copyright 2007, 2009 Free Software Foundation, Inc.
 .\" This file may be copied under the terms of the GNU Public License.
 .\" 
 .\"	.An - list of n alternative values as in "flav vanilla|strawberry"
@@ -48,7 +49,43 @@
 .\"	\(*HO - hash options
 .\"
 .ds HO \fBm\fP|\fBv\fP|\fBt\fP|\fBs\fP|\fBd\fP|\fBf\fP|\fBn\fP|\fBr\fP...
-.TH ETHTOOL 8 "July 2007" "Ethtool version 6"
+.\" Start URL.
+.de UR
+.  ds m1 \\$1\"
+.  nh
+.  if \\n(mH \{\
+.    \" Start diversion in a new environment.
+.    do ev URL-div
+.    do di URL-div
+.  \}
+..
+.\" End URL.
+.de UE
+.  ie \\n(mH \{\
+.    br
+.    di
+.    ev
+.
+.    \" Has there been one or more input lines for the link text?
+.    ie \\n(dn \{\
+.      do HTML-NS "<a href=""\\*(m1"">"
+.      \" Yes, strip off final newline of diversion and emit it.
+.      do chop URL-div
+.      do URL-div
+\c
+.      do HTML-NS </a>
+.    \}
+.    el \
+.      do HTML-NS "<a href=""\\*(m1"">\\*(m1</a>"
+\&\\$*\"
+.  \}
+.  el \
+\\*(la\\*(m1\\*(ra\\$*\"
+.
+.  hy \\n(HY
+..
+
+.TH ETHTOOL 8 "January 2011" "Ethtool version 2.6.37"
 .SH NAME
 ethtool \- Display or change ethernet card settings
 .SH SYNOPSIS
@@ -777,6 +814,6 @@ Scott Feldman,
 Andi Kleen.
 .SH AVAILABILITY
 .B ethtool
-is available over the Web on the SourceForge site at
-http://sourceforge.net/projects/gkernel/
-
+is available from
+.UR http://www.kernel.org/pub/software/network/ethtool/
+.UE
-- 
1.7.3.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

