From: Andi Kleen <ak@muc.de>
Subject: Re: [PATCH] Drop ISA dependencies from IRDA drivers
Date: 15 Jul 2004 22:50:01 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040715205001.GA2527@muc.de>
References: <m34qo96x8m.fsf@averell.firstfloor.org> <40F6B547.7050800@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, irda-users@lists.sourceforge.net, jt@hpl.hp.com,
        the_nihilant@autistici.org,
        Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
Date: Thu, 15 Jul 2004 22:50:01 +0200
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <40F6B547.7050800@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jul 15, 2004 at 12:48:07PM -0400, Jeff Garzik wrote:
> Andi Kleen wrote:
> >http://bugme.osdl.org/show_bug.cgi?id=3077
> >
> >Some IRDA chipsets currently don't work on x86-64, because
> >they're dependent on CONFIG_ISA and x86-64 doesn't set this.
> >CONFIG_ISA means real ISA slots, and I doubt these chips
> >come on real ISA cards, so I just removed the bogus 
> >dependency.
> 
> Honestly, the issue and patch need more thought, IMO.
> 
> Regardless of theory, CONFIG_ISA is currently also used to indicate 
> legacy ISA devices that are today integrated into southbridges.

I don't think so. I did most of the original CONFIG_ISA annotations
and I only added it to real ISA devices.

And the LPC devices in southbridges are normally not marked
CONFIG_ISA. 

> 
> And with legacy ISA devices still around, I don't see a whole lot of 
> value in differentiating between "I have ISA slots" and "I have ISA 
> devices".

There is great value. Basically most ISA drivers are not 64bit 
clean (if they even still work on i386 which is also often doubtful
in 2.6) and it is a great way for 64bit archs to get rid of a lot 
of not working code.

-Andi
