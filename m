From: Jamie Iles <jamie@jamieiles.com>
Subject: Re: [PATCHv2 0/9] macb: add support for Cadence GEM
Date: Thu, 31 Mar 2011 10:40:41 +0100
Message-ID: <20110331094041.GD3371@pulham.picochip.com>
References: <1300184096-13937-1-git-send-email-jamie@jamieiles.com>
 <20110316.131734.242138246.davem@davemloft.net>
 <4D86F25A.7060405@atmel.com>
 <20110321111838.GC2610@pulham.picochip.com>
 <20110322161811.GF6466@game.jcrosoft.org>
 <20110322163917.GD10058@pulham.picochip.com>
 <20110322175523.GE10058@pulham.picochip.com>
 <20110324162517.GI6466@game.jcrosoft.org>
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
Received: from mail-wy0-f174.google.com ([74.125.82.174]:58160 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933413Ab1CaJkq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2011 05:40:46 -0400
Received: by wya21 with SMTP id 21so1848946wya.19
        for <netdev@vger.kernel.org>; Thu, 31 Mar 2011 02:40:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20110324162517.GI6466@game.jcrosoft.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jean-Christophe,

On Thu, Mar 24, 2011 at 05:25:17PM +0100, Jean-Christophe PLAGNIOL-VILLARD wrote:
> On 17:55 Tue 22 Mar     , Jamie Iles wrote:
> > Hi Jean-Christophe,
> > > Also, can you confirm that the module ID's that you are using to 
> > > differentiate between AT91 and AVR32 won't clash with MACB uses in 
> > > other, non-at91/avr32 chips, or that it doesn't matter?
> > 
> > If this does work, then it would be nice if we made the else path of the 
> > RMII AT91 tests also test for avr32 too so we aren't driving the USRIO 
> > pins on platforms that aren't at91 but also aren't avr32.  So something 
> > the patch below instead.
> I'm currently traveling so I can not test it yet will test it next week
> but looks good

Just wondering if you'd had chance to test.  If so, would you mind 
reposting and I'll rebase my patches on top of it.

I also have patches for checksum offloading, receive packet timestamping 
and wake-on-lan support but I'd like to get the basic GEM ones into next 
first.

Jamie
