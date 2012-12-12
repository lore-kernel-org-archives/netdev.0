From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V1 net-next 0/4] Add destination MAC address to ethtool
 flow steering
Date: Wed, 12 Dec 2012 13:03:08 -0500 (EST)
Message-ID: <20121212.130308.47366656526056501.davem@davemloft.net>
References: <1355314400-14909-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, hadarh@mellanox.com,
	yanb@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52721 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754601Ab2LLSDL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 13:03:11 -0500
In-Reply-To: <1355314400-14909-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Wed, 12 Dec 2012 14:13:16 +0200

> From: Yan Burman <yanb@mellanox.com>
> 
> In vSwitch configuration it is often beneficial to create flow steering
> rules for L3/L4 traffic based on VM port. This requires destination MAC
> address of that port to be present. Note that today the mlx4_en driver 
> adds the mac address of itself to the flow spec, where under the new
> ethtool flag suggested here it doesn't.
> 
> It may also be useful in macvlan devices.
> 
> These patches add kernel support for the new field (does not break old
> userspace compatibility, so new ethtool will work on old kernels and
> old ethtool will work with new kernels).
> 
> Also present here is the ethtool userspace patch.
> 
> See more details here http ://marc.info/?t=134977576500003

Kernel side applied to net-next, thanks.
