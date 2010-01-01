From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH] iproute2: avoid using bashisms in configure script.
Date: Fri, 1 Jan 2010 23:20:30 +0100
Message-ID: <20100101222030.GA12149@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxy1.bredband.net ([195.54.101.71]:35560 "EHLO
	proxy1.bredband.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751941Ab0AAWRU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jan 2010 17:17:20 -0500
Received: from ipb2.telenor.se (195.54.127.165) by proxy1.bredband.net (7.3.140.3)
        id 4AD3E1C0021723E1 for netdev@vger.kernel.org; Fri, 1 Jan 2010 23:17:15 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"function foo" should be "foo()" to work when sh is not bash.

Signed-off-by: Andreas Henriksson <andreas@fatal.se>
---

Sorry for not getting this right the first time around....

--- a/configure
+++ b/configure
@@ -3,7 +3,7 @@
 #
 INCLUDE=${1:-"$PWD/include"}
 
-function check_atm
+check_atm()
 {
 cat >/tmp/atmtest.c <<EOF
 #include <atm.h>
@@ -24,7 +24,7 @@ fi
 rm -f /tmp/atmtest.c /tmp/atmtest
 }
 
-function check_xt
+check_xt()
 {
 #check if we have xtables from iptables >= 1.4.5.
 cat >/tmp/ipttest.c <<EOF
@@ -55,7 +55,7 @@ fi
 rm -f /tmp/ipttest.c /tmp/ipttest
 }
 
-function check_xt_old
+check_xt_old()
 {
 # bail if previous XT checks has already succeded.
 if grep TC_CONFIG_XT Config > /dev/null
@@ -94,7 +94,7 @@ fi
 rm -f /tmp/ipttest.c /tmp/ipttest
 }
 
-function check_xt_old_internal_h
+check_xt_old_internal_h()
 {
 # bail if previous XT checks has already succeded.
 if grep TC_CONFIG_XT Config > /dev/null
@@ -134,7 +134,7 @@ fi
 rm -f /tmp/ipttest.c /tmp/ipttest
 }
 
-function check_ipt
+check_ipt()
 {
 	if ! grep TC_CONFIG_XT Config > /dev/null
 	then
