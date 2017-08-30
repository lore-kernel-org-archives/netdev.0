From: Haiyang Zhang <haiyangz@exchange.microsoft.com>
Subject: [PATCH net-next] hv_netvsc: Fix typos in the document of UDP hashing
Date: Wed, 30 Aug 2017 13:37:22 -0700
Message-ID: <20170830203722.18780-1-haiyangz@exchange.microsoft.com>
Reply-To: haiyangz@microsoft.com
Cc: haiyangz@microsoft.com, kys@microsoft.com, olaf@aepfle.de,
        vkuznets@redhat.com, linux-kernel@vger.kernel.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a2nlsmtp01-04.prod.iad2.secureserver.net ([198.71.225.38]:38016
        "EHLO a2nlsmtp01-04.prod.iad2.secureserver.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751318AbdH3Uic (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 16:38:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haiyang Zhang <haiyangz@microsoft.com>

There are two typos in the document, netvsc.txt,
regarding UDP hashing level. This patch fixes them.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 Documentation/networking/netvsc.txt | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/netvsc.txt b/Documentation/networking/netvsc.txt
index fa8d86356791..93560fb1170a 100644
--- a/Documentation/networking/netvsc.txt
+++ b/Documentation/networking/netvsc.txt
@@ -32,9 +32,9 @@ Features
   hashing. Using L3 hashing is recommended in this case.
 
   For example, for UDP over IPv4 on eth0:
-  To include UDP port numbers in hasing:
+  To include UDP port numbers in hashing:
         ethtool -N eth0 rx-flow-hash udp4 sdfn
-  To exclude UDP port numbers in hasing:
+  To exclude UDP port numbers in hashing:
         ethtool -N eth0 rx-flow-hash udp4 sd
   To show UDP hash level:
         ethtool -n eth0 rx-flow-hash udp4
-- 
2.14.1
