From: David Miller <davem@davemloft.net>
Subject: Re: smc91x: commit 51ac3beffd4afaea4350526cf01fe74aaff25eff breaks
 compilation
Date: Mon, 03 Nov 2008 00:08:58 -0800 (PST)
Message-ID: <20081103.000858.141796921.davem@davemloft.net>
References: <20081103073534.GA18445@roarinelk.homelinux.net>
	<1aad82fa0811022348of69b7a0v10f4eb97a8a3f6df@mail.gmail.com>
	<20081103080340.GC18445@roarinelk.homelinux.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vapier@gentoo.org, netdev@vger.kernel.org
To: mano@roarinelk.homelinux.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53027
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753238AbYKCIJW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 03:09:22 -0500
In-Reply-To: <20081103080340.GC18445@roarinelk.homelinux.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manuel Lauss <mano@roarinelk.homelinux.net>
Date: Mon, 3 Nov 2008 09:03:40 +0100

> To be more precise:
> 
> smc91x configured purely through platform_data:
> 
> ATTRIB_SIZE is ((64*1024) << SMC_IO_SHIFT)
> with SMC_IO_SHIFT being "lp->io_shift" (smc91x.h line 450).
> 
> So please revert this patch.

That's not the correct action, because that brings the
stupid warning back in some configurations.

See my other reply for the fix I'll be using, which
brings back the variables but adds the appropriate
__maybe_unused markers to them.
