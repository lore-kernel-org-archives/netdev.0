From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 3/5] forcedeth: ethtool tx csum fix
Date: Fri, 06 Feb 2009 14:27:25 -0500
Message-ID: <498C8F1D.9070700@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040506010200080003040803"
To: Manfred Spraul <manfred@colorfullife.com>,
	Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
	"David S. Miller" <davem@davemloft.net>,
	nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.112.145]:19146 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750831AbZBFW2n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 17:28:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040506010200080003040803
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch fixes the ethtool tx csum "set" command. A recent patch was
submitted to remove HW_CSUM and use IP_CSUM instead. Therefore, the
corresponding ethtool command should also be modified.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>



--------------040506010200080003040803
Content-Type: text/plain;
 name="patch-forcedeth-txcsum"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-txcsum"

--- old/drivers/net/forcedeth.c	2009-02-06 14:15:38.000000000 -0500
+++ new/drivers/net/forcedeth.c	2009-02-06 14:15:55.000000000 -0500
@@ -4763,7 +4763,7 @@
 	struct fe_priv *np = netdev_priv(dev);
 
 	if (np->driver_data & DEV_HAS_CHECKSUM)
-		return ethtool_op_set_tx_hw_csum(dev, data);
+		return ethtool_op_set_tx_csum(dev, data);
 	else
 		return -EOPNOTSUPP;
 }

--------------040506010200080003040803--
