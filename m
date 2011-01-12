From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 3/7] ethtool.8: Substitute version at configure time
Date: Wed, 12 Jan 2011 16:22:34 +0000
Message-ID: <1294849354.3946.3.camel@bwh-desktop>
References: <1294849266.3946.0.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:54103 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752640Ab1ALQWh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jan 2011 11:22:37 -0500
In-Reply-To: <1294849266.3946.0.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename ethtool.8 to ethtool.8.in and let autoconf set the version.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

diff --git a/configure.ac b/configure.ac
index 9bc8c26..a96fd4d 100644
--- a/configure.ac
+++ b/configure.ac
@@ -29,5 +29,5 @@ dnl Checks for library functions.
 AC_HEADER_STDC
 AC_CHECK_FUNCS(socket strtol)
 
-AC_CONFIG_FILES([Makefile ethtool.spec])
+AC_CONFIG_FILES([Makefile ethtool.spec ethtool.8])
 AC_OUTPUT
diff --git a/ethtool.8 b/ethtool.8.in
similarity index 99%
rename from ethtool.8
rename to ethtool.8.in
index 8c2137b..75f63ba 100644
--- a/ethtool.8
+++ b/ethtool.8.in
@@ -85,7 +85,7 @@
 .  hy \\n(HY
 ..
 
-.TH ETHTOOL 8 "January 2011" "Ethtool version 2.6.37"
+.TH ETHTOOL 8 "January 2011" "Ethtool version @VERSION@"
 .SH NAME
 ethtool \- Display or change ethernet card settings
 .SH SYNOPSIS
-- 
1.7.3.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

