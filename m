From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 06/10] {NET,IB}/mlx4: Add device managed flow
 steering firmware API
Date: Mon, 2 Jul 2012 19:07:25 +0100
Message-ID: <1341252445.2590.12.camel@bwh-desktop.uk.solarflarecom.com>
References: <4FF042B5.1000303@mellanox.com>
	 <20120701.144252.792146486861614931.davem@davemloft.net>
	 <4FF153F0.8080707@mellanox.com>
	 <20120702.013445.1273332212099485403.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <ogerlitz@mellanox.com>, <roland@kernel.org>,
	<yevgenyp@mellanox.com>, <oren@mellanox.com>,
	<netdev@vger.kernel.org>, <hadarh@mellanox.co.il>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:59189 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932293Ab2GBSH3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 14:07:29 -0400
In-Reply-To: <20120702.013445.1273332212099485403.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-07-02 at 01:34 -0700, David Miller wrote:
> From: Or Gerlitz <ogerlitz@mellanox.com>
> Date: Mon, 2 Jul 2012 10:55:28 +0300
> 
> > On 7/2/2012 12:42 AM, David Miller wrote:
> >> [...] Module parameters stink because every driver is going to provide
> >> the knob differently, with a different name, and different
> >> semantics. This creates a terrible user experience, and I will not
> >> allow it.
> > 
> > OK, so if looking on what we are left with on the table, seems that
> > sysfs entry on the mlx4_core
> > level (as we do for the port link type {IB, Eth} or IB port MTU) could
> > be fine here, Roland, agree?
> 
> No way.
> 
> You have to create a real interface, that other vendors with similar
> chips can consistently use.

But there may not be enough commonality to define a non- vendor-specific
API.  And ethtool really isn't a good way to expose parameters that are
per-controller rather than per-net-device, particularly if changing them
may disrupt all running net devices on that controller and not just the
one used to invoke SIOCETHTOOL.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
