From: Adrian Bunk <bunk@kernel.org>
Subject: Re: blackfin drivers/net/smc91x.c build error
Date: Tue, 10 Jun 2008 20:34:50 +0300
Message-ID: <20080610173450.GC11685@cs181133002.pp.htv.fi>
References: <20080606162212.GC2201@cs181133002.pp.htv.fi> <8bd0f97a0806061252n1cf5ee33i40ddf9f55588e242@mail.gmail.com> <20080610135349.GA30792@cs181133002.pp.htv.fi> <8bd0f97a0806101013w42b9028j5dfa38d654f3d05f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Bryan Wu <cooloney@kernel.org>, Jeff Garzik <jeff@garzik.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Mike Frysinger <vapier.adi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6.pp.htv.fi ([213.243.153.40]:48085 "EHLO smtp6.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753019AbYFJRft (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jun 2008 13:35:49 -0400
Content-Disposition: inline
In-Reply-To: <8bd0f97a0806101013w42b9028j5dfa38d654f3d05f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 10, 2008 at 01:13:52PM -0400, Mike Frysinger wrote:
> On Tue, Jun 10, 2008 at 9:53 AM, Adrian Bunk wrote:
> > On Fri, Jun 06, 2008 at 03:52:09PM -0400, Mike Frysinger wrote:
> >> On Fri, Jun 6, 2008 at 12:22 PM, Adrian Bunk wrote:
> >> > drivers/net/smc91x.c fails as follows on blackfin:
> >> > ...
> >> >  CC      drivers/net/smc91x.o
> >> > ...
> >> > /home/bunk/linux/kernel-2.6/git/linux-2.6/drivers/net/smc91x.c:1863:36: error: macro "SMC_GET_MAC_ADDR" passed 2 arguments, but takes just 1
> >> > ...
> >>
> >> it's a known issue (been known for quite a long time actually).  Bryan
> >> has brought this up in the past already.
> >
> > Is my suggestion of reverting commit 099c736a470c8080a166e7a089f1e48e15f9947c
> > correct or how else should it be resolved?
> 
> Bryan is taking care of it ... it may just stay broken in favor of
> waiting for the merge from the net tree.
> 
> > This issue is the only remaining problem preventing that all blackfin
> > defconfigs will compile in 2.6.26...
> 
> not really true.
>...

What other build errors do you get in Linus' tree?

> -mike

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

