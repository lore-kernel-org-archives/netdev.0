From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Subject: Re: [PATCHv2 0/9] macb: add support for Cadence GEM
Date: Thu, 24 Mar 2011 17:25:17 +0100
Message-ID: <20110324162517.GI6466@game.jcrosoft.org>
References: <1300184096-13937-1-git-send-email-jamie@jamieiles.com>
 <20110316.131734.242138246.davem@davemloft.net>
 <4D86F25A.7060405@atmel.com>
 <20110321111838.GC2610@pulham.picochip.com>
 <20110322161811.GF6466@game.jcrosoft.org>
 <20110322163917.GD10058@pulham.picochip.com>
 <20110322175523.GE10058@pulham.picochip.com>
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
Received: from 63.mail-out.ovh.net ([91.121.185.56]:51666 "HELO
	63.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751458Ab1CXQcA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2011 12:32:00 -0400
Content-Disposition: inline
In-Reply-To: <20110322175523.GE10058@pulham.picochip.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17:55 Tue 22 Mar     , Jamie Iles wrote:
> Hi Jean-Christophe,
> 
> On Tue, Mar 22, 2011 at 04:39:17PM +0000, Jamie Iles wrote:
> > Hi Jean-Christophe,
> > 
> > On Tue, Mar 22, 2011 at 05:18:11PM +0100, Jean-Christophe PLAGNIOL-VILLARD wrote:
> > > On 11:18 Mon 21 Mar     , Jamie Iles wrote:
> > > > I have an existing tree for this at
> > > > 
> > > > 	git://github.com/jamieiles/linux-2.6-ji.git macb-gem
> > > > 
> > > > based off of 2.6.38 (with your ACK's now added) and I'd be happy with 
> > > > either route.
> > > but we must detect the gem via the version register and ditto for macb for
> > > avr32 and at91
> > > 
> > > so please rebase it over my patch
> > > 
> > > and you get my sob too
> > 
> > Would you mind respinning your patch without the changes to the clk 
> > stuff?  Otherwise we're changing it from compile time to version based, 
> > only to completely remove it in subsequent patches.
> 
> Actually, this patch doesn't work anyway as the version register is 
> being read before the clks are enabled so the device isn't accessible 
> (and the registers haven't yet been ioremap()'d).
yeah I found it also I forget to put he RFC in the patch title as I want just to
give the way to detect it the way to detect it for avr32 and at91
so we can remove the ifdef fully
> 
> > Also, can you confirm that the module ID's that you are using to 
> > differentiate between AT91 and AVR32 won't clash with MACB uses in 
> > other, non-at91/avr32 chips, or that it doesn't matter?
> 
> If this does work, then it would be nice if we made the else path of the 
> RMII AT91 tests also test for avr32 too so we aren't driving the USRIO 
> pins on platforms that aren't at91 but also aren't avr32.  So something 
> the patch below instead.
I'm currently traveling so I can not test it yet will test it next week
but looks good

Best Regards,
J.
