From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 02/12] switchdev: Make flood to CPU optional
Date: Wed, 28 Oct 2015 10:16:55 +0100
Message-ID: <1446023825-7162-3-git-send-email-jiri@resnulli.us>
References: <1446023825-7162-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, sagir@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:37598 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932657AbbJ1JRS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2015 05:17:18 -0400
Received: by wicfv8 with SMTP id fv8so4705837wic.0
        for <netdev@vger.kernel.org>; Wed, 28 Oct 2015 02:17:16 -0700 (PDT)
In-Reply-To: <1446023825-7162-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

In certain use cases it is not always desirable for the switch device to
flood traffic to CPU port. Instead, only certain packet types (e.g.
STP, LACP) should be trapped to it.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 Documentation/networking/switchdev.txt | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/switchdev.txt b/Documentation/networking/switchdev.txt
index ce510e1..9199413 100644
--- a/Documentation/networking/switchdev.txt
+++ b/Documentation/networking/switchdev.txt
@@ -278,8 +278,8 @@ Flooding L2 domain
 For a given L2 VLAN domain, the switch device should flood multicast/broadcast
 and unknown unicast packets to all ports in domain, if allowed by port's
 current STP state.  The switch driver, knowing which ports are within which
-vlan L2 domain, can program the switch device for flooding.  The packet should
-also be sent to the port netdev for processing by the bridge driver.  The
+vlan L2 domain, can program the switch device for flooding.  The packet may
+be sent to the port netdev for processing by the bridge driver.  The
 bridge should not reflood the packet to the same ports the device flooded,
 otherwise there will be duplicate packets on the wire.
 
-- 
1.9.3
