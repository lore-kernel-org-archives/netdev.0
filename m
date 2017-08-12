From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 48/51] ifcfg: Quote left-hand side of [ ] expression
Date: Sat, 12 Aug 2017 14:05:07 +0200
Message-ID: <20170812120510.28750-49-phil@nwl.cc>
References: <20170812120510.28750-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:37655 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752347AbdHLMHK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Aug 2017 08:07:10 -0400
In-Reply-To: <20170812120510.28750-1-phil@nwl.cc>
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
