From: Jamie Iles <jamie@jamieiles.com>
Subject: Re: [PATCHv2 0/9] macb: add support for Cadence GEM
Date: Tue, 22 Mar 2011 16:39:17 +0000
Message-ID: <20110322163917.GD10058@pulham.picochip.com>
References: <1300184096-13937-1-git-send-email-jamie@jamieiles.com>
 <20110316.131734.242138246.davem@davemloft.net>
 <4D86F25A.7060405@atmel.com>
 <20110321111838.GC2610@pulham.picochip.com>
 <20110322161811.GF6466@game.jcrosoft.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamie Iles <jamie@jamieiles.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	David Miller <davem@davemloft.net>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Andrew Victor <linux@maxim.org.za>,
	Peter Korsgaard <jacmet@sunsite.dk>
To: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:52698 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751680Ab1CVQjd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2011 12:39:33 -0400
Received: by wwa36 with SMTP id 36so9046705wwa.1
        for <netdev@vger.kernel.org>; Tue, 22 Mar 2011 09:39:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20110322161811.GF6466@game.jcrosoft.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jean-Christophe,

On Tue, Mar 22, 2011 at 05:18:11PM +0100, Jean-Christophe PLAGNIOL-VILLARD wrote:
> On 11:18 Mon 21 Mar     , Jamie Iles wrote:
> > I have an existing tree for this at
> > 
> > 	git://github.com/jamieiles/linux-2.6-ji.git macb-gem
> > 
> > based off of 2.6.38 (with your ACK's now added) and I'd be happy with 
> > either route.
> but we must detect the gem via the version register and ditto for macb for
> avr32 and at91
> 
> so please rebase it over my patch
> 
> and you get my sob too

Would you mind respinning your patch without the changes to the clk 
stuff?  Otherwise we're changing it from compile time to version based, 
only to completely remove it in subsequent patches.

Also, can you confirm that the module ID's that you are using to 
differentiate between AT91 and AVR32 won't clash with MACB uses in 
other, non-at91/avr32 chips, or that it doesn't matter?

Jamie
