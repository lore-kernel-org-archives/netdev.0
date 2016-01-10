From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 8/8] switchdev: Adding IGMP snooping documentation
Date: Sun, 10 Jan 2016 14:07:28 +0100
Message-ID: <1452431248-5411-9-git-send-email-jiri@resnulli.us>
References: <1452431248-5411-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, corbet@lwn.net,
	stephen@networkplumber.org, sfeldma@gmail.com,
	vivien.didelot@savoirfairelinux.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:38464 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756432AbcAJNHm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 08:07:42 -0500
Received: by mail-wm0-f44.google.com with SMTP id b14so231831464wmb.1
        for <netdev@vger.kernel.org>; Sun, 10 Jan 2016 05:07:42 -0800 (PST)
In-Reply-To: <1452431248-5411-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Raz <eladr@mellanox.com>

Signed-off-by: Elad Raz <eladr@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 Documentation/networking/switchdev.txt | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/switchdev.txt b/Documentation/networking/switchdev.txt
index 9199413..fad6313 100644
--- a/Documentation/networking/switchdev.txt
+++ b/Documentation/networking/switchdev.txt
@@ -304,8 +304,12 @@ certain netdevs from flooding unicast traffic for which there is no FDB entry.
 IGMP Snooping
 ^^^^^^^^^^^^^
 
-XXX: complete this section
-
+In order to support IGMP snooping, the port netdevs should trap to the bridge
+driver all IGMP join and leave messages.
+The bridge multicast module will notify port netdevs on every multicast group
+changed whether it is static configured or dynamically joined/leave.
+The hardware implementation should be forwarding all registered multicast
+traffic groups only to the configured ports.
 
 L3 Routing Offload
 ------------------
-- 
1.9.3
