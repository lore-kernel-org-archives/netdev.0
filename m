From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Subject: Re: [PATCHv2 0/9] macb: add support for Cadence GEM
Date: Tue, 22 Mar 2011 17:18:11 +0100
Message-ID: <20110322161811.GF6466@game.jcrosoft.org>
References: <1300184096-13937-1-git-send-email-jamie@jamieiles.com>
 <20110316.131734.242138246.davem@davemloft.net>
 <4D86F25A.7060405@atmel.com>
 <20110321111838.GC2610@pulham.picochip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
	David Miller <davem@davemloft.net>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Andrew Victor <linux@maxim.org.za>,
	Peter Korsgaard <jacmet@sunsite.dk>
To: Jamie Iles <jamie@jamieiles.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 63.mail-out.ovh.net ([91.121.185.56]:49479 "HELO
	63.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751368Ab1CVQYk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2011 12:24:40 -0400
Content-Disposition: inline
In-Reply-To: <20110321111838.GC2610@pulham.picochip.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11:18 Mon 21 Mar     , Jamie Iles wrote:
> On Mon, Mar 21, 2011 at 02:38:18PM +0800, Nicolas Ferre wrote:
> > On 3/17/2011 4:17 AM, David Miller :
> > > From: Jamie Iles <jamie@jamieiles.com>
> > > Date: Tue, 15 Mar 2011 10:14:47 +0000
> > > 
> > >> This patch series extends the Atmel MACB driver to support the Cadence
> > >> GEM (Gigabit Ethernet MAC) to support 10/100 operation.  The GEM is
> > >> based on the MACB block but has a few moved registers and bitfields.
> > >> This patch series attempts to use the MACB accessors where block
> > >> functionallity is identical and only overrides to GEM specific
> > >> acccessors when needed.
> > >>
> > >> This has been runtested on a board with a Cadence GEM and compile tested
> > >> for all at91 configurations and a number of avr32 configurations.
> > >>
> > >> Changes since v1:
> > >> 	- AT91 now provides a fake "hclk" and "macb_clk" has been
> > >> 	renamed to "pclk" to be consistent with AVR32.
> > >> 	- Configurable GEM receive buffer size support has been added.
> > >> 	- pr_foo() and dev_foo() have been converted to netdev_foo()
> > >> 	where appropriate.
> > >> 	- New conditional accessors (macb_or_gem_{read,write}l) have
> > >> 	been introduced that do the conditional accesses dependent on
> > >> 	macb/gem type.
> > >> 	- GEM is now dynamically detected from the module ID rather than
> > >> 	platform device name.
> > >>
> > >> Jean-Christophe, I haven't based this on your conditional clock patch as
> > >> I wasn't sure what decision had been made on that and whether the
> > >> at91/avr32 detection is reliable.
> > > 
> > > I'm happy to ACK this so you guys can merge this via one of the
> > > ARM trees:
> > > 
> > > Acked-by: David S. Miller <davem@davemloft.net>
> > 
> > I add my:
> > 
> > Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>
> > 
> > Now, tell me if we need to setup a git tree with this and make it 
> > handled by linux-next (we do not have for at91 yet)?
> > or Russell can take the series in a "devel" branch?
> 
> Thanks for testing Nicolas!
> 
> I have an existing tree for this at
> 
> 	git://github.com/jamieiles/linux-2.6-ji.git macb-gem
> 
> based off of 2.6.38 (with your ACK's now added) and I'd be happy with 
> either route.
but we must detect the gem via the version register and ditto for macb for
avr32 and at91

so please rebase it over my patch

and you get my sob too

Best Regards,
J.
