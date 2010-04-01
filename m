From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 1/2] phylib: Support phy module autoloading
Date: Thu, 1 Apr 2010 19:05:12 +0100
Message-ID: <20100401180511.GQ16821@decadent.org.uk>
References: <1269998334.18090.278.camel@macbook.infradead.org> <1270096441.12516.18.camel@localhost> <1270141428.3101.399.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, 553024@bugs.debian.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:52698 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758670Ab0DASFY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 14:05:24 -0400
Content-Disposition: inline
In-Reply-To: <1270141428.3101.399.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 01, 2010 at 06:03:48PM +0100, David Woodhouse wrote:
> On Thu, 2010-04-01 at 05:34 +0100, Ben Hutchings wrote:
[...]
> > Since you've dealt with (a), and (b) is not really as important, I would
> > just like to suggest some minor changes to your patch 1 (see below).
> > Feel free to fold them in.  Your patch 2 would then need the
> > substitutions s/phy_device_id/mdio_device_id/; s/TABLE(phy/TABLE(mdio/.
> 
> I'll tolerate the silly __u32 crap if I must for consistency, but
> normally I prefer to write in C.
> 
> I did think about 'mdio:' for the module alias, but I decided that
> 'phy:' probably made more sense since these are PHY driver modules and
> the number is the phy_id.
[...]

Many multi-layered communication standards have distinct PHY devices,
and they presumably have their own ID spaces.  phylib deals only with
management of Ethernet PHYs over an MDIO bus, identified using MDIO
ID registers.

Ben.

-- 
Ben Hutchings
We get into the habit of living before acquiring the habit of thinking.
                                                              - Albert Camus
