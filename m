From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 2/2] ethtool: Remove specification of number bases
 for RX-ntuple parameters
Date: Thu, 22 Jul 2010 20:12:44 +0100
Message-ID: <1279825964.2104.29.camel@achroite.uk.solarflarecom.com>
References: <1279825899.2104.28.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:36930 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752768Ab0GVTMr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 15:12:47 -0400
In-Reply-To: <1279825899.2104.28.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The numeric parameters for RX n-tuple filters may be specified as
either decimal or hexadecimal with a '0x' prefix, like most other
numeric parameters.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.8 |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/ethtool.8 b/ethtool.8
index d0cbc93..98b57fb 100644
--- a/ethtool.8
+++ b/ethtool.8
@@ -689,28 +689,28 @@ Includes the destination IP address.
 Specify a mask for the destination IP address.
 .TP
 .BI src-port \ port
-Includes the source port, specified in decimal.
+Includes the source port.
 .TP
 .BI src-port-mask \ mask
-Specify a mask for the source port, specified in hex.
+Specify a mask for the source port.
 .TP
 .BI dst-port \ port
-Includes the destination port, specified in decimal.
+Includes the destination port.
 .TP
 .BI dst-port-mask \ mask
-Specify a mask for the destination port, specified in hex.
+Specify a mask for the destination port.
 .TP
 .BI vlan \ VLAN-tag
-Includes the VLAN tag, specified in hex.
+Includes the VLAN tag.
 .TP
 .BI vlan-mask \ mask
-Specify a mask for the VLAN tag, specified in hex.
+Specify a mask for the VLAN tag.
 .TP
 .BI user-def \ data
-Includes 64-bits of user-specific data, specified in hex.
+Includes 64-bits of user-specific data.
 .TP
 .BI user-def-mask \ mask
-Specify a mask for the user-specific data, specified in hex.
+Specify a mask for the user-specific data.
 .TP
 .BI action \ N
 Specifies either the Rx queue to send packets to, or to drop
-- 
1.6.2.5

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

