From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Regression: e100_phy_init() isolates even selected
 PHY, causes 10 seconds boot delay
Date: Thu, 29 Oct 2009 06:02:39 -0700 (PDT)
Message-ID: <20091029.060239.202729106.davem@davemloft.net>
References: <4AC3C09B.3040203@gmx.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bruce.w.allan@intel.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org
To: bernhard.kaindl@gmx.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44026
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752370AbZJ2NCP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 09:02:15 -0400
In-Reply-To: <4AC3C09B.3040203@gmx.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bernhard Kaindl <bernhard.kaindl@gmx.net>
Date: Wed, 30 Sep 2009 22:33:31 +0200

> The current e100.c:e100_phy_init() electrically isolates all
> the PHYs (even the selected PHY -- for a short time!) from the MII.
> 
> This happens only for a short duration before the isolation
> of the selected PHY is reverted, but it's enough to cause a
> major disturbance in the startup of our e100-based cards:
> 
> On a number of Embedded/Industry Pentium boards which are in use,
> the result is that the initial DHCP negotiation takes more
> than 10 seconds to complete with 2.6.30 and .31, while it's
> done in a fraction of a second with 2.6.29 and earlier
> (kernels tested with no delay range from 2.6.23 to 2.6.29)
> 
> That regression was introduced on March 31 in the by a patch
> from Bruce which first appeared in 2.6.30-rc3:

Bruce, can you give some feedback on this?  I'd like to see this issue
move forward.

The only reason I haven't applied Bernhard's patch is because I
haven't seen any feedback from Intel.  But I will apply it anyways if
I don't see reasonable feedback soon.

Thanks.
