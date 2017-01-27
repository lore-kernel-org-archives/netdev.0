From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/4] sfc: encapsulated filters
Date: Fri, 27 Jan 2017 11:59:53 -0500 (EST)
Message-ID: <20170127.115953.1732560410043160047.davem@davemloft.net>
References: <9baa375c-b3b1-f640-04fb-e234c85a4e93@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, netdev@vger.kernel.org
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43244 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932162AbdA0RK4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 12:10:56 -0500
In-Reply-To: <9baa375c-b3b1-f640-04fb-e234c85a4e93@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Fri, 27 Jan 2017 15:00:45 +0000

> This series adds support for setting up filters for encapsulated traffic on
> SFC 8000-series adapters, which recognise VXLAN, GENEVE and NVGRE packets by
> parsing packet headers.  (VXLAN and GENEVE will only be recognised if the
> driver on the primary PF has notified the firmware of relevant UDP ports,
> which this driver does not yet do.)
> While the driver currently has no way of using these filters for flow
> steering, it is nonetheless necessary to insert catch-all (aka 'default')
> filters to direct this traffic, similar to the existing unencapsulated uni-
> and multi-cast catch-all filters, as otherwise the traffic will be dropped
> by the NIC - implementation details of the hardware filtering mean that the
> traffic will not get matched on outer MAC address to unencapsulated catch-
> all filters.  (Yes, this is a mess.)
> Although this is, therefore, fixing a bug in the existing driver, it's a bug
> which has existed since 8000 series support was added, and the fix involves
> quite a big patch with an 'adding features' flavour to it, hence why this is
> for net-next rather than net and stable.
> 
> v2: move netif_cond_dbg into netdevice.h and its own patch

Yes, this looks better, series applied.

Thanks!
