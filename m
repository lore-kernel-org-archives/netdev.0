From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: vrf: Address comments from last documentation update
Date: Wed, 13 Jul 2016 18:28:16 -0600
Message-ID: <1468456096-11495-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33695 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751492AbcGNA2U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2016 20:28:20 -0400
Received: by mail-pa0-f52.google.com with SMTP id ks6so22513182pab.0
        for <netdev@vger.kernel.org>; Wed, 13 Jul 2016 17:28:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Comments from Frank Kellerman on last doc update:
- extra whitespace in front of a neigh show command
- convert the brief link example to 'vrf red'

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 Documentation/networking/vrf.txt | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/vrf.txt b/Documentation/networking/vrf.txt
index 11a2b99bdbb9..755dab856392 100644
--- a/Documentation/networking/vrf.txt
+++ b/Documentation/networking/vrf.txt
@@ -189,7 +189,7 @@ older form without it.
 
 
    Or using the brief output:
-   $ ip -br link show master red
+   $ ip -br link show vrf red
    eth1             UP             02:00:00:00:02:02 <BROADCAST,MULTICAST,UP,LOWER_UP>
    eth2             UP             02:00:00:00:02:03 <BROADCAST,MULTICAST,UP,LOWER_UP>
    eth5             DOWN           02:00:00:00:02:06 <BROADCAST,MULTICAST>
@@ -207,8 +207,8 @@ older form without it.
    10.2.1.254 dev eth1 lladdr a6:d9:c7:4f:06:23 REACHABLE
    10.2.2.254 dev eth2 lladdr 5e:54:01:6a:ee:80 REACHABLE
 
-    $ ip -6 neigh show vrf red
-    2002:1::64 dev eth1 lladdr a6:d9:c7:4f:06:23 REACHABLE
+   $ ip -6 neigh show vrf red
+   2002:1::64 dev eth1 lladdr a6:d9:c7:4f:06:23 REACHABLE
 
 
 6. Show Addresses for a VRF
-- 
2.7.4 (Apple Git-66)
