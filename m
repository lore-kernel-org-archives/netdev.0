From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] [PATCH] Optimize TCP sendmsg in favour of fast devices?
Date: Thu, 21 Jan 2010 01:25:20 -0800 (PST)
Message-ID: <20100121.012520.254679483.davem@davemloft.net>
References: <OF0D3FEC3A.84663D58-ON652576AC.0031CA59-652576AC.003232CF@in.ibm.com>
	<20100115.011829.03057807.davem@davemloft.net>
	<OF0A3AFFAB.FFA8088C-ON652576B1.001D7B08-652576B1.0042980B@in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52668
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754739Ab0AUJZJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2010 04:25:09 -0500
In-Reply-To: <OF0A3AFFAB.FFA8088C-ON652576B1.001D7B08-652576B1.0042980B@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar2 <krkumar2@in.ibm.com>
Date: Wed, 20 Jan 2010 17:49:18 +0530

> I had to remove the F_SG flag from cxgb3 driver (using ethtool
> didn't show any difference in performance since GSO was enabled
> on the device due to register_netdev setting it). Testing show a
> drop of 25% in performance with this patch for non-SG device,
> the extra alloc/memcpy is showing up.
> 
> For the SG driver, I get a good performace gain (not anywhere
> close to 25% though). What do you suggest?

I don't think we can add your change if it hurts non-SG
devices that much.
