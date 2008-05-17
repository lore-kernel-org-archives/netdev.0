From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [PATCH] drivers/net: remove network drivers' last few uses of
	IRQF_SAMPLE_RANDOM
Date: Sun, 18 May 2008 01:02:58 +0300
Message-ID: <20080517220258.GC8140@cs181133002.pp.htv.fi>
References: <Pine.LNX.4.62.0805150009060.18303@ikari.dreamhost.com> <20080515142154.0595e475@core> <36D9DB17C6DE9E40B059440DB8D95F52052D71BB@orsmsx418.amr.corp.intel.com> <482C7B18.6060003@garzik.org> <482C7E53.3050300@hp.com> <482C8184.2030906@garzik.org> <20080516161029.44ded734@core> <0f7201c8b790$9c2a2340$f9b5a8c0@pii350>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Gilles Espinasse <g.esp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6.pp.htv.fi ([213.243.153.40]:50068 "EHLO smtp6.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750767AbYEQWEx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 May 2008 18:04:53 -0400
Content-Disposition: inline
In-Reply-To: <0f7201c8b790$9c2a2340$f9b5a8c0@pii350>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 16, 2008 at 10:08:29PM +0200, Gilles Espinasse wrote:
> 
> That's funny
> It does look to disturb some kernel developper that ethernet may be sniffed
> to feed a RNG
> even that could be very hard to reach any effective result in the case of a
> machine splitting
> different network segments.
> 
> In the same time, it does not disturb openssl developpers to include non
> initialised
> memory that may or may not be predictable to feed a RNG.
> http://marc.info/?l=openssl-dev&m=121095151003011&w=2

Why should it disturb them?

As is explained in the email you quote it cannot make the RNG
output worse.

>  Gilles

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

