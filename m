From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net v2 1/4] net: mvpp2: fix the mac address used when
 using PPv2.2
Date: Fri, 25 Aug 2017 16:19:39 +0200
Message-ID: <20170825141939.GB30922@lunn.ch>
References: <20170825141420.14027-1-antoine.tenart@free-electrons.com>
 <20170825141420.14027-2-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, thomas.petazzoni@free-electrons.com,
        gregory.clement@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com, netdev@vger.kernel.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44193 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754777AbdHYOTq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Aug 2017 10:19:46 -0400
Content-Disposition: inline
In-Reply-To: <20170825141420.14027-2-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 25, 2017 at 04:14:17PM +0200, Antoine Tenart wrote:
> The mac address is only retrieved from h/w when using PPv2.1. Otherwise
> the variable holding it is still checked and used if it contains a valid
> value. As the variable isn't initialized to an invalid mac address
> value, we end up with random mac addresses which can be the same for all
> the ports handled by this PPv2 driver.
> 
> Fixes this by initializing the h/w mac address variable to {0}, which is
> an invalid mac address value. This way the random assignation fallback
> is called and all ports end up with their own addresses.
> 
> Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
> Fixes: 2697582144dd ("net: mvpp2: handle misc PPv2.1/PPv2.2 differences")

Hi Antoine

Is this patch alone sufficient to fix the problem?

Ideally, you want a minimal patch for stable, i.e. -net, and a fuller
fix can go into net-next.

    Andrew
