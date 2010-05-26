From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH] ethtool: Fix list of hash options in manual page
Date: Wed, 26 May 2010 02:15:11 +0100
Message-ID: <1274836511.19775.3.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: =?ISO-8859-1?Q?An=EDbal?= Monsalve Salazar <anibal@debian.org>,
	netdev <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:47912 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759143Ab0EZBPW convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 May 2010 21:15:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

'p' is not a valid option.
The 'm' option was missing a preceding 'B' for bold.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
--- ethtool-2.6.34.orig/ethtool.8
+++ ethtool-2.6.34/ethtool.8
@@ -47,7 +47,7 @@
 .\"
 .\"	\(*HO - hash options
 .\"
-.ds HO \fBp\fP|\fm\fP|\fBv\fP|\fBt\fP|\fBs\fP|\fBd\fP|\fBf\fP|\fBn\fP|\fBr\fP...
+.ds HO \fBm\fP|\fBv\fP|\fBt\fP|\fBs\fP|\fBd\fP|\fBf\fP|\fBn\fP|\fBr\fP...
 .TH ETHTOOL 8 "July 2007" "Ethtool version 6"
 .SH NAME
 ethtool \- Display or change ethernet card settings

-- 
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.
