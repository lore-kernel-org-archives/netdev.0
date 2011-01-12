From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 7/7] ethtool.8: Fix capitalisation
Date: Wed, 12 Jan 2011 16:23:21 +0000
Message-ID: <1294849401.3946.7.camel@bwh-desktop>
References: <1294849266.3946.0.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:54176 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751900Ab1ALQXY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jan 2011 11:23:24 -0500
In-Reply-To: <1294849266.3946.0.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Write 'Ethernet' and 'PHY' thus.

Use the proper macro for the trademark symbol.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

diff --git a/ethtool.8.in b/ethtool.8.in
index 203d33d..0ee91a0 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -337,10 +337,10 @@ settings of the specified device.
 Shows a short help message.
 .TP
 .B \-a \-\-show\-pause
-Queries the specified ethernet device for pause parameter information.
+Queries the specified Ethernet device for pause parameter information.
 .TP
 .B \-A \-\-pause
-Changes the pause parameters of the specified ethernet device.
+Changes the pause parameters of the specified Ethernet device.
 .TP
 .A2 autoneg on off
 Specifies whether pause autonegotiation should be enabled.
@@ -456,7 +456,7 @@ Length of time to perform phys-id, in seconds.
 Queries the specified network device for permanent hardware address.
 .TP
 .B \-r \-\-negotiate
-Restarts auto-negotiation on the specified ethernet device, if
+Restarts auto-negotiation on the specified Ethernet device, if
 auto-negotiation is enabled.
 .TP
 .B \-S \-\-statistics
@@ -535,7 +535,7 @@ this option is a string of characters specifying which options to enable.
 .PD 0
 .TP 3
 .B p
-Wake on phy activity
+Wake on PHY activity
 .TP 3
 .B u
 Wake on unicast messages
@@ -550,10 +550,10 @@ Wake on broadcast messages
 Wake on ARP
 .TP 3
 .B g
-Wake on MagicPacket(tm)
+Wake on MagicPacket\[tm]
 .TP 3
 .B s
-Enable SecureOn(tm) password for MagicPacket(tm)
+Enable SecureOn\[tm] password for MagicPacket\[tm]
 .TP 3
 .B d
 Disable (wake on nothing).  This option clears all previous options.
@@ -561,8 +561,8 @@ Disable (wake on nothing).  This option clears all previous options.
 .RE
 .TP
 .B sopass \*(MA\c
-Sets the SecureOn(tm) password.  The argument to this option must be 6
-bytes in ethernet MAC hex format (\*(MA).
+Sets the SecureOn\[tm] password.  The argument to this option must be 6
+bytes in Ethernet MAC hex format (\*(MA).
 .PP
 .BI msglvl \ N
 .br
-- 
1.7.3.4


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

