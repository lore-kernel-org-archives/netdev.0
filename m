From: Jamie Iles <jamie@jamieiles.com>
Subject: Re: [PATCHv2 3/9] macb: unify at91 and avr32 platform data
Date: Fri, 18 Mar 2011 15:48:39 +0000
Message-ID: <20110318154839.GB3393@pulham.picochip.com>
References: <1300184096-13937-1-git-send-email-jamie@jamieiles.com>
 <1300184096-13937-4-git-send-email-jamie@jamieiles.com>
 <87vczkmy94.fsf@macbook.be.48ers.dk>
 <AANLkTi=TiRnc0ceosH-P7fN7wKrLZE0MCJHQ30gM_Q9b@mail.gmail.com>
 <871v26m8tf.fsf@macbook.be.48ers.dk>
 <20110317085835.GC29758@n2100.arm.linux.org.uk>
 <87wrjyksnm.fsf@macbook.be.48ers.dk>
 <20110317093403.GA15396@pulham.picochip.com>
 <20110317215101.GC2927@pulham.picochip.com>
 <20110318154118.GQ29758@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamie Iles <jamie@jamieiles.com>,
	Peter Korsgaard <jacmet@sunsite.dk>,
	"avictor.za@gmail.com" <avictor.za@gmail.com>,
	plagnioj@jcrosoft.com, linux-arm-kernel@lists.infradead.org,
	nicolas.ferre@atmel.com, netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41789 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754184Ab1CRPuL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 11:50:11 -0400
Received: by wya21 with SMTP id 21so3977555wya.19
        for <netdev@vger.kernel.org>; Fri, 18 Mar 2011 08:50:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20110318154118.GQ29758@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 18, 2011 at 03:41:18PM +0000, Russell King - ARM Linux wrote:
> On Thu, Mar 17, 2011 at 09:51:01PM +0000, Jamie Iles wrote:
> > On Thu, Mar 17, 2011 at 09:34:03AM +0000, Jamie Iles wrote:
> > > Ok, I'll rename to macb_platform_data and update at91_ether to use 
> > > that with a comment describing that we're sharing the platform data 
> > > with macb.  At least that gets rid of the preprocessor stuff in 
> > > board.h for at91 too.
> > 
> > So here's the updated patch with changes to the at91_ether driver to 
> > share the data with macb.
> > 
> > Russell, are you happy to take this series?  If so, how would you prefer 
> > it, in the patch system or as a git pull?
> 
> As Nicolas Ferre is listed in MAINTAINERS as being responsible for the
> MACB driver, I think he should at last Ack these patches first.

OK, that's absolutely fine with me.

> I'm also concious of the fact that Linus complains if my tree contains
> changes for drivers/ stuff as well as ARM stuff, so I'm nervous about
> taking it as-is.  So, I'd rather see drivers stuff separated as much
> as possible from the arch updates.

I happy to split the driver and arch updates, but I'm not sure that it 
can be done in such a way that platforms would build between the arch 
and driver merges.

> I'm also concious that this has become ready for potentially merging
> during the merge window, and therefore hasn't had previous exposure
> in linux-next, and so should wait until the next merge window.  I do
> feel that I'm going to be yelled at for saying that... but I'm sure
> I'll also be yelled at if I did take it.

I don't have any problem with waiting until the next merge window, and 
to be honest I'd like see these patches have some time in next as I 
can't test them on devices with a MACB.

Jamie
