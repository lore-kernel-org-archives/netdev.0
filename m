From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [patch 3/4] Configure out ethtool support
Date: Thu, 31 Jul 2008 18:58:20 +0300
Message-ID: <20080731155820.GC20212@cs181140183.pp.htv.fi>
References: <1217500967.3454.140.camel@pmac.infradead.org> <20080731.035121.177567346.davem@davemloft.net> <1217503770.3454.162.camel@pmac.infradead.org> <20080731.043355.143045459.davem@davemloft.net> <1217504801.3454.170.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>,
	thomas.petazzoni@free-electrons.com, linux-kernel@vger.kernel.org,
	linux-embedded@vger.kernel.org, michael@free-electrons.com,
	mpm@selenic.com, jgarzik@pobox.com, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5.pp.htv.fi ([213.243.153.39]:42536 "EHLO smtp5.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752861AbYGaP7Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jul 2008 11:59:16 -0400
Content-Disposition: inline
In-Reply-To: <1217504801.3454.170.camel@pmac.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 31, 2008 at 12:46:41PM +0100, David Woodhouse wrote:
> On Thu, 2008-07-31 at 04:33 -0700, David Miller wrote:
> > From: David Woodhouse <dwmw2@infradead.org>
> > Date: Thu, 31 Jul 2008 12:29:30 +0100
> > 
> > > After an offline discussion, I understand that if we can sort out the
> > > actual technical issues, you'll carry this in the net tree. Thanks.
> > 
> > I will, but only because you threatened to bypass me and send them
> > directly to Linus.  And frankly fighting someone willing to do things
> > like that is simply not worth my time, so I'll just merge them
> > blindly.
> 
> That doesn't make a lot of sense, Dave. Just because I _submit_ them to
> Linus, that doesn't mean he automatically takes them.
> 
> I only said I'd submit them directly to Linus because I _think_ he'd
> agree with Andrew and I, and take them despite your objections. And
> because I think that's the right thing for him to do.
>...

I'm sure we can find simpler and less controversial ways to save 6 kB in 
the network stack. E.g. Ilpo's past work on making inline functions in 
the network stack out-of-line had far bigger effects than the patch in 
this discussion. And as a bonus, his work brings benefits to everyone.

It might have also made more sense to spend some of the energy used in 
this discussion instead on checking where the global 24 kB size increase 
Thomas reported for 2.6.27-rc1 compared to 2.6.26 comes from.

It's kinda silly to spend time on creating and arguing about non-trivial 
patches that might save a few kB for very few people while noone seems 
to work on reducing the continuous size increase of the kernel that 
affects everyone...

> dwmw2

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

