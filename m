From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/6] net: vlan: add 802.1ad support
Date: Fri, 19 Apr 2013 16:08:48 -0400 (EDT)
Message-ID: <20130419.160848.369413926403305345.davem@davemloft.net>
References: <1366373072-19621-1-git-send-email-kaber@trash.net>
	<1366373072-19621-6-git-send-email-kaber@trash.net>
	<1366401783.2716.10.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47189 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753600Ab3DSUIv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 16:08:51 -0400
In-Reply-To: <1366401783.2716.10.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 19 Apr 2013 21:03:03 +0100

> These need to be given names in the netdev_features_strings array in
> net/core/ethtool.c

Thanks, I'm about to commit the following:

====================
[PATCH] net: Add missing netdev feature strings for NETIF_F_HW_VLAN_STAG_*

Noticed by Ben Hutchings.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/ethtool.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index b87712c..5a934ef 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -64,6 +64,9 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
 
 	[NETIF_F_HW_VLAN_CTAG_RX_BIT] =  "rx-vlan-ctag-hw-parse",
 	[NETIF_F_HW_VLAN_CTAG_FILTER_BIT] = "rx-vlan-ctag-filter",
+	[NETIF_F_HW_VLAN_STAG_TX_BIT] =  "tx-vlan-stag-hw-insert",
+	[NETIF_F_HW_VLAN_STAG_RX_BIT] =  "rx-vlan-stag-hw-parse",
+	[NETIF_F_HW_VLAN_STAG_FILTER_BIT] = "rx-vlan-stag-filter",
 	[NETIF_F_VLAN_CHALLENGED_BIT] =  "vlan-challenged",
 	[NETIF_F_GSO_BIT] =              "tx-generic-segmentation",
 	[NETIF_F_LLTX_BIT] =             "tx-lockless",
-- 
1.7.11.7
