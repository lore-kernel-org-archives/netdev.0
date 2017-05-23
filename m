From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v2 net-next 1/2] Documentation: sysfs-class-net-statistics: Clarify rx_bytes and tx_bytes
Date: Tue, 23 May 2017 23:10:57 +0200
Message-ID: <1495573858-32346-2-git-send-email-andrew@lunn.ch>
References: <1495573858-32346-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        hayeswang <hayeswang@realtek.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42164 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1162002AbdEWVLi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 May 2017 17:11:38 -0400
In-Reply-To: <1495573858-32346-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Document what is expected for the rx_bytes and tx_bytes statistics in
/sys/class/net/<device>/statistics. The FCS should be included in the
statistics. However, since this has been unclear until now, it is
expected a number of drivers don't. But maybe with time they will.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 Documentation/ABI/testing/sysfs-class-net-statistics | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/Documentation/ABI/testing/sysfs-class-net-statistics b/Documentation/ABI/testing/sysfs-class-net-statistics
index 397118de7b5e..a487cbb79458 100644
--- a/Documentation/ABI/testing/sysfs-class-net-statistics
+++ b/Documentation/ABI/testing/sysfs-class-net-statistics
@@ -21,7 +21,8 @@ Contact:	netdev@vger.kernel.org
 Description:
 		Indicates the number of bytes received by this network device.
 		See the network driver for the exact meaning of when this
-		value is incremented.
+		value is incremented. However, for an Ethernet frame, it should
+		include the Ethernet header, data, and frame check sum.
 
 What:		/sys/class/<iface>/statistics/rx_compressed
 Date:		April 2005
@@ -125,7 +126,8 @@ Description:
 		device. See the network driver for the exact meaning of this
 		value, in particular whether this accounts for all successfully
 		transmitted packets or all packets that have been queued for
-		transmission.
+		transmission. For an Ethernet frame, it should include the
+		Ethernet header, data, and frame check sum.
 
 What:		/sys/class/<iface>/statistics/tx_carrier_errors
 Date:		April 2005
-- 
2.11.0
