From: Jamie Iles <jamie@jamieiles.com>
Subject: Re: [PATCHv2 0/9] macb: add support for Cadence GEM
Date: Tue, 5 Apr 2011 12:47:55 +0100
Message-ID: <20110405114754.GG4797@pulham.picochip.com>
References: <4D86F25A.7060405@atmel.com>
 <20110321111838.GC2610@pulham.picochip.com>
 <20110322161811.GF6466@game.jcrosoft.org>
 <20110322163917.GD10058@pulham.picochip.com>
 <20110322175523.GE10058@pulham.picochip.com>
 <20110324162517.GI6466@game.jcrosoft.org>
 <20110331094041.GD3371@pulham.picochip.com>
 <20110405102842.GC22192@game.jcrosoft.org>
 <20110405104910.GE4797@pulham.picochip.com>
 <20110405112102.GB19268@game.jcrosoft.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamie Iles <jamie@jamieiles.com>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	netdev@vger.kernel.org, Nicolas Ferre <nicolas.ferre@atmel.com>,
	David Miller <davem@davemloft.net>,
	Peter Korsgaard <jacmet@sunsite.dk>,
	Andrew Victor <linux@maxim.org.za>,
	linux-arm-kernel@lists.infradead.org
To: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37827 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752886Ab1DELr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 07:47:59 -0400
Received: by wya21 with SMTP id 21so241727wya.19
        for <netdev@vger.kernel.org>; Tue, 05 Apr 2011 04:47:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20110405112102.GB19268@game.jcrosoft.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 05, 2011 at 01:21:02PM +0200, Jean-Christophe PLAGNIOL-VILLARD wrote:
> On 11:49 Tue 05 Apr     , Jamie Iles wrote:
> > On Tue, Apr 05, 2011 at 12:28:42PM +0200, Jean-Christophe PLAGNIOL-VILLARD wrote:
> > > work fine on 9263ek except the IP version detection.
> > > 
> > > the at91 macb ip version is supposed to be at 0x0601010C but it's not.
> > > At least on 9263 it's 0x0001010C. So we can not detect the arch at runtime
> > > but we can detect that it's a macb.
> > > 
> > > So could keep the ifdef for 2 archs but use the ip version on arm
> > 
> > OK, well I think my patches are already doing that so should be OK as 
> > they are.
> > 
> > Russell, are you able to take these through your tree (I think they 
> > count as consolidation work) or should I ask Stephen for a tree in 
> > linux-next for a while first?
> no please do not us the is_gem but the same way as I did in the ip detection
> keep the version register and then check it.
> 
> as this ip can be used on other arch we do not want to see thousands 
> of is_xxx

But GEM isn't an architecture/machine type, it's a new Cadence Ethernet 
controller that follows on from MACB, not some arch specific tweaks so 
we really only have two options - MACB or GEM.

Still, if it's important to you then I'll make the change.

Jamie
