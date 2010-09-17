From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethtool: change ethtool_set_gro() to use
 ethtool_op_get_rx_csum
Date: Fri, 17 Sep 2010 11:57:07 -0700 (PDT)
Message-ID: <20100917.115707.106807995.davem@davemloft.net>
References: <20100915.233851.85414928.davem@davemloft.net>
	<1284619376.2462.95.camel@edumazet-laptop>
	<1284624663.3352.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, bphilips@suse.de,
	e1000-devel@lists.sourceforge.net, bruce.w.allan@intel.com,
	jesse.brandeburg@intel.com, john.ronciak@intel.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50472
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754475Ab0IQS4s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Sep 2010 14:56:48 -0400
In-Reply-To: <1284624663.3352.9.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 16 Sep 2010 10:11:03 +0200

> [PATCH] ethtool: change ethtool_set_gro() to use ethtool_op_get_rx_csum
> 
> To be able to switch on GRO on a device, ethtool_set_gro() checks this
> device provides a get_rx_csum() method.
> 
> Some devices dont provide this method, while they do support RX
> checksumming.
> 
> This patch allows bonding to support GRO :
> 
> ethtool -K bond0 gro on
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.

Can you do whatever change is needed to get it enabled by default?

Thanks again.
