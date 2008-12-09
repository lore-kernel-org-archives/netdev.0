From: David Miller <davem@davemloft.net>
Subject: Re: sumgem problems with initializiation order at a 1000SX SERDES
 card [experimental patch]
Date: Tue, 09 Dec 2008 00:06:31 -0800 (PST)
Message-ID: <20081209.000631.18791640.davem@davemloft.net>
References: <20081128000059.GA13712@lemon.iwr.uni-heidelberg.de>
	<20081204.173324.136036003.davem@davemloft.net>
	<20081208155936.GD16754@lemon.iwr.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hermann.Lauer@iwr.uni-heidelberg.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43118
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751962AbYLIIGa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 03:06:30 -0500
In-Reply-To: <20081208155936.GD16754@lemon.iwr.uni-heidelberg.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hermann Lauer <Hermann.Lauer@iwr.uni-heidelberg.de>
Date: Mon, 8 Dec 2008 16:59:36 +0100

> On Thu, Dec 04, 2008 at 05:33:24PM -0800, David Miller wrote:
> 
> > And this new code is just a copy of the PHY init sequence on
> > PCS, so we should split that out into a helper function instead
> > of duplicating it.
> > 
> > Any time gem_reset() is invoked, the PCS is going to need to be
> > reset like this, so let's do the advertisement reinit there.
> > 
> > Does this version of the fix work for you?
> 
> Yes, works the same. It has some delay before receiving packets works
> after an ifconfig up or a reestablishing of the link, but thats
> the same as with the experimental patch.
> Probably the link state handling has to be improved, I'm not
> shure my experimental patch was correct there.
> 
> But as the driver is working now with this patch on this hardware
> and not without - please commit.

I agree, and that's what I'll do.

Thanks for testing.
