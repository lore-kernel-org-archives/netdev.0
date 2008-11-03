From: Manuel Lauss <mano@roarinelk.homelinux.net>
Subject: Re: smc91x: commit 51ac3beffd4afaea4350526cf01fe74aaff25eff breaks
	compilation
Date: Mon, 3 Nov 2008 09:14:12 +0100
Message-ID: <20081103081412.GD18445@roarinelk.homelinux.net>
References: <20081103073534.GA18445@roarinelk.homelinux.net> <1aad82fa0811022348of69b7a0v10f4eb97a8a3f6df@mail.gmail.com> <20081103080340.GC18445@roarinelk.homelinux.net> <20081103.000858.141796921.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vapier@gentoo.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fnoeppeil48.netpark.at ([217.175.205.176]:57636 "EHLO
	roarinelk.homelinux.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753238AbYKCIOO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 03:14:14 -0500
Content-Disposition: inline
In-Reply-To: <20081103.000858.141796921.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 03, 2008 at 12:08:58AM -0800, David Miller wrote:
> From: Manuel Lauss <mano@roarinelk.homelinux.net>
> Date: Mon, 3 Nov 2008 09:03:40 +0100
> 
> > To be more precise:
> > 
> > smc91x configured purely through platform_data:
> > 
> > ATTRIB_SIZE is ((64*1024) << SMC_IO_SHIFT)
> > with SMC_IO_SHIFT being "lp->io_shift" (smc91x.h line 450).
> > 
> > So please revert this patch.
> 
> That's not the correct action, because that brings the
> stupid warning back in some configurations.
> 
> See my other reply for the fix I'll be using, which
> brings back the variables but adds the appropriate
> __maybe_unused markers to them.

Thank you.  I sent the above reply before your fix hit my
mailbox.  I don't really care _how_ it's being fixed, I just
want the damn thing to work ;-)

Thanks again,
	Manuel Lauss

