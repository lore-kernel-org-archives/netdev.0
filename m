From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 3/5] forcedeth: ethtool tx csum fix
Date: Fri, 30 Jan 2009 13:56:35 -0500
Message-ID: <49834D63.9080902@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010306030206000301030306"
To: Manfred Spraul <manfred@colorfullife.com>,
	Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
	"David S. Miller" <davem@davemloft.net>,
	nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate04.nvidia.com ([216.228.112.152]:15715 "EHLO
	hqemgate04.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755884AbZA3WCI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 17:02:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010306030206000301030306
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch fixes the ethtool tx csum "set" command. A recent patch was 
submitted to remove HW_CSUM and use IP_CSUM instead. Therefore, the 
corresponding ethtool command should also be modified.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>


--------------010306030206000301030306
Content-Type: text/plain;
 name="patch-forcedeth-txcsum"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-txcsum"

--- old/drivers/net/forcedeth.c	2009-01-30 13:32:20.000000000 -0500
+++ new/drivers/net/forcedeth.c	2009-01-30 13:32:37.000000000 -0500
@@ -4750,7 +4750,7 @@
 	struct fe_priv *np = netdev_priv(dev);
 
 	if (np->driver_data & DEV_HAS_CHECKSUM)
-		return ethtool_op_set_tx_hw_csum(dev, data);
+		return ethtool_op_set_tx_csum(dev, data);
 	else
 		return -EOPNOTSUPP;
 }

--------------010306030206000301030306--
