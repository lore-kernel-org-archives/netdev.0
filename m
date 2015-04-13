From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2 1/3] Revert "configure: add missing INCLUDE to netnsid detection"
Date: Mon, 13 Apr 2015 10:23:03 +0200
Message-ID: <1428913385-4331-1-git-send-email-nicolas.dichtel@6wind.com>
References: <5527F790.4080301@6wind.com>
Cc: netdev@vger.kernel.org, vadim4j@gmail.com, jbenc@redhat.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:40921 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751604AbbDMIXN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 04:23:13 -0400
In-Reply-To: <5527F790.4080301@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit d059de70cafb470f77fc19a42d95f6dc442cf6a3.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 configure | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/configure b/configure
index e54f4b6db5e8..631938e97206 100755
--- a/configure
+++ b/configure
@@ -224,7 +224,7 @@ check_netnsid()
 #include <linux/rtnetlink.h>
 int test_def = RTM_GETNSID;
 EOF
-    $CC -I$INCLUDE -c $TMPDIR/netnsid.c >/dev/null 2>&1
+    $CC -c $TMPDIR/netnsid.c >/dev/null 2>&1
     if [ $? -eq 0 ]
     then
 	echo "IP_CONFIG_NETNSID:=y" >> Config
-- 
2.2.2
