From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net: Expose header length compution
 function
Date: Fri, 09 May 2014 16:24:54 -0400 (EDT)
Message-ID: <20140509.162454.1317479460010270185.davem@davemloft.net>
References: <1399553434-25617-1-git-send-email-amirv@mellanox.com>
	<1399553434-25617-2-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idos@mellanox.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	alexander.h.duyck@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com, yevgenyp@mellanox.com,
	ogerlitz@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39440 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756929AbaEIUY5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 16:24:57 -0400
In-Reply-To: <1399553434-25617-2-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Thu,  8 May 2014 15:50:33 +0300

> From: Ido Shamay <idos@mellanox.com>
> 
> This commit exposes an header length compution generic function,
> introduced in some of Intel's Etherent drivers (igb and ixgbe),
> to net public namespace under the name __net_get_headlen,
> where it can be used by other vendors and removes code duplication.
> 
> Signed-off-by: Ido Shamay <idos@mellanox.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>

First of all, this appears (at least to me) to duplicate a lot of
what the existing flow dissector can do.

For example, you can probably call skb_flow_dissect() and the
filled in flow_keys has much of what you need.  If it doesn't
have everything you need consider extending it.

Even if that won't work out, you must add a detailed comment, with
kernel doc, above the declaration for this new interface in the
header file.

I honestly still have no idea exactly what this function does and
exactly what it's trying to achieve.
