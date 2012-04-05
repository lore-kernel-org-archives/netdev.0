From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V7 0/8] net/mlx4_en: DCB QoS support
Date: Thu, 05 Apr 2012 05:28:28 -0400 (EDT)
Message-ID: <20120405.052828.1474884969422039237.davem@davemloft.net>
References: <1333611211-1032-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roland@purestorage.com,
	yevgenyp@mellanox.com, oren@mellanox.com, amirv@dev.mellanox.co.il,
	john.r.fastabend@intel.com, eric.dumazet@gmail.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54543 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753572Ab2DEJ2q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2012 05:28:46 -0400
In-Reply-To: <1333611211-1032-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Thu,  5 Apr 2012 10:33:23 +0300

> DCBX version 802.1qaz is supported.
> User Priority (UP) is set in QP context instead of in WQE (QP Work Queue
> Element), which means that all traffic from a queue will have the same UP.
> UP is also set for untagged traffic to be able to classify such traffic too.
> 
> Mapping from sk_prio to User Priority is done by sch_mqprio mapping. Although
> confusingly sch_mqprio maps sk_prio to something called TC, it is not related
> to DCBX's TC, and is interpreted by mlx4_en driver as UP.
> 
> User can set maximal BW for an ETS TC. This could be done by a new optional
> attribute added to DCB_ATTR_IEEE called DCBNL DCB_ATTR_IEEE_MAXRATE. It accept
> an array of 8 64 bits values, 1 for every ETS TC. Units are in Kbps.

All applied, thanks.

Please double check that all the new locations that reference
ip_tos2prio have a proper dependency on CONFIG_INET.

THanks.
