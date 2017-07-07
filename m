From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net] doc: SKB_GSO_[IPIP|SIT] have been replaced
Date: Fri,  7 Jul 2017 14:08:25 +0200
Message-ID: <20170707120825.9691-1-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        Tom Herbert <tom@herbertland.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:39803 "EHLO
        proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750941AbdGGMIi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2017 08:08:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Those enum values don't exist anymore.

Fixes: 7e13318daa4a ("net: define gso types for IPx over IPv4 and IPv6")
CC: Tom Herbert <tom@herbertland.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 Documentation/networking/segmentation-offloads.txt | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Documentation/networking/segmentation-offloads.txt b/Documentation/networking/segmentation-offloads.txt
index f200467ade38..2f09455a993a 100644
--- a/Documentation/networking/segmentation-offloads.txt
+++ b/Documentation/networking/segmentation-offloads.txt
@@ -55,7 +55,7 @@ IPIP, SIT, GRE, UDP Tunnel, and Remote Checksum Offloads
 In addition to the offloads described above it is possible for a frame to
 contain additional headers such as an outer tunnel.  In order to account
 for such instances an additional set of segmentation offload types were
-introduced including SKB_GSO_IPIP, SKB_GSO_SIT, SKB_GSO_GRE, and
+introduced including SKB_GSO_IPXIP4, SKB_GSO_IPXIP6, SKB_GSO_GRE, and
 SKB_GSO_UDP_TUNNEL.  These extra segmentation types are used to identify
 cases where there are more than just 1 set of headers.  For example in the
 case of IPIP and SIT we should have the network and transport headers moved
-- 
2.13.2
