From: Jason Lunz <lunz@falooley.org>
Subject: Re: [PATCH] 2.4.20-pre sundance.c update
Date: Thu, 19 Sep 2002 00:56:21 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020919045621.GA11144@orr.falooley.org>
References: <20020828185612.GA14342@reflexsecurity.com> <20020828231333.GA15183@reflexsecurity.com> <200209190353.g8J3r5q28456@vindaloo.ras.ucalgary.ca> <20020919041403.GA10527@orr.falooley.org> <3D89519C.1020809@mandrakesoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Richard Gooch <rgooch@ras.ucalgary.ca>,
   becker@scyld.com, "Patrick R. McManus" <mcmanus@ducksong.com>,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@mandrakesoft.com>
Content-Disposition: inline
In-Reply-To: <3D89519C.1020809@mandrakesoft.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Sep 19, 2002 at 12:25AM -0400, Jeff Garzik wrote:
> It still has several flaws that were pointed out, but this is the base 
> from which I would like testing and patching to proceed.  (also 
> hopefully the flaws are minor in terms of general operation)

what's the point of moving rx handling into rx_poll then running it in a
tasklet? I've tested an older variant of that scheme from D-Link and it
doesn't perform as well as my patch. It looks to me like an attempt to
keep this version synced with the NAPI version of the driver, but it
doesn't actually work very well.

The functional part of my patch was just taking the tx handling from
d-link's driver and ditching the rx part.  That and merging in the
cleanups from Becker's driver; most notably ignoring the broken
IntrRxDone bit.

Jason
