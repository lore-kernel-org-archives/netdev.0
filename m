From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 2/2] ifcfg: Quote left-hand side of [ ] expression
Date: Thu, 17 Aug 2017 19:09:32 +0200
Message-ID: <20170817170932.24900-3-phil@nwl.cc>
References: <20170817170932.24900-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:47533 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753692AbdHQROH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 13:14:07 -0400
In-Reply-To: <20170817170932.24900-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This prevents word-splitting and therefore leads to more accurate error
message in case 'grep -c' prints something other than a number.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ifcfg | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/ifcfg b/ip/ifcfg
index 083d9df36742f..30a2dc49816cd 100644
--- a/ip/ifcfg
+++ b/ip/ifcfg
@@ -131,7 +131,7 @@ noarp=$?
 
 ip route add unreachable 224.0.0.0/24 >& /dev/null
 ip route add unreachable 255.255.255.255 >& /dev/null
-if [ `ip link ls $dev | grep -c MULTICAST` -ge 1 ]; then
+if [ "`ip link ls $dev | grep -c MULTICAST`" -ge 1 ]; then
   ip route add 224.0.0.0/4 dev $dev scope global >& /dev/null
 fi
 
-- 
2.13.1
