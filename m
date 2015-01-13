From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH 1/6] net: davinci_emac: Fix hangs with interrupts
Date: Tue, 13 Jan 2015 11:45:06 -0800
Message-ID: <20150113194506.GF2419@atomide.com>
References: <1421177368-19756-1-git-send-email-tony@atomide.com>
 <1421177368-19756-2-git-send-email-tony@atomide.com>
 <20150113193634.GQ16533@saruman>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-omap@vger.kernel.org, Brian Hutchinson <b.hutchman@gmail.com>
To: Felipe Balbi <balbi@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mho-02-ewr.mailhop.org ([204.13.248.72]:33192 "EHLO
	mho-02-ewr.mailhop.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751085AbbAMTsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 14:48:52 -0500
Content-Disposition: inline
In-Reply-To: <20150113193634.GQ16533@saruman>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Felipe Balbi <balbi@ti.com> [150113 11:40]:
> On Tue, Jan 13, 2015 at 11:29:23AM -0800, Tony Lindgren wrote:
> > 
> > Note that eventually we should handle the RX and TX interrupts
> > separately like cpsw is now doing. However, so far I have not seen
> > any issues with this based on my testing, so it seems to behave a
> > little different compared to the cpsw that had a similar issue.
> 
> pretty much the same thing that happens with CPSW, I think that a future
> patch might want to change things so that we only write EOI to the IRQ
> that actually fires, though.

Yeah I agree that's totally the way to go for the future. I've tried to
expose that issue here with nuttcp but so far no luck.

Regards,

Tony 
