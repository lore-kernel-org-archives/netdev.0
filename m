From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan: enable GRO if real_dev supports it
Date: Wed, 15 Sep 2010 10:29:58 -0700 (PDT)
Message-ID: <20100915.102958.48514267.davem@davemloft.net>
References: <1284570520.2462.5.camel@edumazet-laptop>
	<20100915.101418.59680213.davem@davemloft.net>
	<1284571476.2293.5.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, bphilips@suse.de,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, alexander.h.duyck@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com,
	donald.c.skidmore@intel.com, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58389
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752707Ab0IOR3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 13:29:40 -0400
In-Reply-To: <1284571476.2293.5.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 15 Sep 2010 18:24:36 +0100

> On Wed, 2010-09-15 at 10:14 -0700, David Miller wrote:
>> I think a better way to implement this is to set NETIF_F_GRO in
>> netdev->vlan_features at register_netdev() time if it is set in
>> netdev->features
>> 
>> That is the implementation I was implying earlier in this thread.
> 
> We can even add it unconditionally there, since we only ever use
> dev->features & dev->vlan_features.

Good point!
