From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Subject: Re: [PATCHv2 0/9] macb: add support for Cadence GEM
Date: Tue, 5 Apr 2011 12:28:42 +0200
Message-ID: <20110405102842.GC22192@game.jcrosoft.org>
References: <1300184096-13937-1-git-send-email-jamie@jamieiles.com>
 <20110316.131734.242138246.davem@davemloft.net>
 <4D86F25A.7060405@atmel.com>
 <20110321111838.GC2610@pulham.picochip.com>
 <20110322161811.GF6466@game.jcrosoft.org>
 <20110322163917.GD10058@pulham.picochip.com>
 <20110322175523.GE10058@pulham.picochip.com>
 <20110324162517.GI6466@game.jcrosoft.org>
 <20110331094041.GD3371@pulham.picochip.com>
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
Received: from 63.mail-out.ovh.net ([91.121.185.56]:50464 "HELO
	63.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752568Ab1DEKgW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 06:36:22 -0400
Content-Disposition: inline
In-Reply-To: <20110331094041.GD3371@pulham.picochip.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10:40 Thu 31 Mar     , Jamie Iles wrote:
> Hi Jean-Christophe,
> 
> On Thu, Mar 24, 2011 at 05:25:17PM +0100, Jean-Christophe PLAGNIOL-VILLARD wrote:
> > On 17:55 Tue 22 Mar     , Jamie Iles wrote:
> > > Hi Jean-Christophe,
> > > > Also, can you confirm that the module ID's that you are using to 
> > > > differentiate between AT91 and AVR32 won't clash with MACB uses in 
> > > > other, non-at91/avr32 chips, or that it doesn't matter?
> > > 
> > > If this does work, then it would be nice if we made the else path of the 
> > > RMII AT91 tests also test for avr32 too so we aren't driving the USRIO 
> > > pins on platforms that aren't at91 but also aren't avr32.  So something 
> > > the patch below instead.
> > I'm currently traveling so I can not test it yet will test it next week
> > but looks good
> 
> Just wondering if you'd had chance to test.  If so, would you mind 
> reposting and I'll rebase my patches on top of it.
> 
> I also have patches for checksum offloading, receive packet timestamping 
> and wake-on-lan support but I'd like to get the basic GEM ones into next 
> first.
work fine on 9263ek except the IP version detection.

the at91 macb ip version is supposed to be at 0x0601010C but it's not.
At least on 9263 it's 0x0001010C. So we can not detect the arch at runtime
but we can detect that it's a macb.

So could keep the ifdef for 2 archs but use the ip version on arm

Best Regards,
J.
