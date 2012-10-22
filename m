From: Florian Fainelli <ffainelli@freebox.fr>
Subject: Re: [PATCH] e1000: fix concurrent accesses to PHY from watchdog and ethtool
Date: Mon, 22 Oct 2012 10:28:26 +0200
Message-ID: <2571860.cVpYZJtmi6@flexo>
References: <1350650688-29293-1-git-send-email-ffainelli@freebox.fr> <1350715654.2213.22.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7Bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Maxime Bizon <mbizon@freebox.fr>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:35728 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750848Ab2JVI3p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2012 04:29:45 -0400
In-Reply-To: <1350715654.2213.22.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 19 October 2012 23:47:34 Jeff Kirsher wrote:
> On Fri, 2012-10-19 at 14:44 +0200, Florian Fainelli wrote:
> > From: Maxime Bizon <mbizon@freebox.fr>
> > 
> > The e1000 driver currently does not protect concurrent accesses to the
> > PHY
> > from both the ethtool callbacks, and from the e1000_watchdog function.
> > This
> > patchs adds a new spinlock which is used by e1000_{read,write}_phy_reg
> > in
> > order to serialize concurrent accesses to the PHY.
> > 
> > Signed-off-by: Maxime Bizon <mbizon@freebox.fr>
> > Signed-off-by: Florian Fainelli <ffainelli@freebox.fr>
> > ---
> >  drivers/net/ethernet/intel/e1000/e1000_hw.c |   17 +++++++++++++++--
> >  1 file changed, 15 insertions(+), 2 deletions(-) 
> 
> It does not appear I have responded yet, so...
> 
> I have added this patch to my queue, thanks!

Thanks Jeff, I will let you decide whether you think this is relevant for being
included into -stable releases.
--
Florian
