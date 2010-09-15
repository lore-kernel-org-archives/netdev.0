From: Brandon Philips <bphilips@suse.de>
Subject: Re: [PATCH] ixgbe: add GRO to vlan_features
Date: Wed, 15 Sep 2010 09:38:09 -0700
Message-ID: <20100915163809.GB4191@mmm.home.ifup.org>
References: <20100915015052.GA6602@mmm.home.ifup.org>
 <20100914.213544.112598547.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, alexander.h.duyck@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com,
	donald.c.skidmore@intel.com, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:33619 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754484Ab0IOQlk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Sep 2010 12:41:40 -0400
Content-Disposition: inline
In-Reply-To: <20100914.213544.112598547.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21:35 Tue 14 Sep 2010, David Miller wrote:
> From: Brandon Philips <bphilips@suse.de>
> Date: Tue, 14 Sep 2010 18:50:53 -0700
> 
> > When running a vlan -> bridge -> domU setup I was noticing poor RX
> > performance. It seems ixgbe and other drivers don't have NETIF_F_GRO set
> > in vlan_features and thus GRO is off by default for vlans.
> > 
> > I see no reason why the other drivers shouldn't be fixed. If this is OK
> > I will go off and fix the rest.
> > 
> > Signed-off-by: Brandon Philips <bphilips@suse.de>
> 
> I think it should be set, but why don't we do this another way?
> 
> This feature is a software feature, essentially, so if it is published
> in netdev->features we can simply propagate it automatically to
> netdev->vlan_features at device registry time in the core networking.

Agreed. I will just send a patch to vlan_dev.c then.
