From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [git patches] net driver fixes
Date: Tue, 16 Sep 2008 13:48:11 +0300
Message-ID: <20080916104811.GC7397@cs181140183.pp.htv.fi>
References: <20080915204543.GD3994@havoc.gtf.org> <20080915.141442.139271313.davem@davemloft.net> <20080915215307.GA10340@alpha.franken.de> <20080915.151125.93659986.davem@davemloft.net> <20080916083934.GA7397@cs181140183.pp.htv.fi> <20080916091808.GA5938@alpha.franken.de> <20080916094011.GB7397@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, jeff@garzik.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.pp.htv.fi ([213.243.153.38]:56738 "EHLO smtp4.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752228AbYIPKs2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Sep 2008 06:48:28 -0400
Content-Disposition: inline
In-Reply-To: <20080916094011.GB7397@cs181140183.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 16, 2008 at 12:40:14PM +0300, Adrian Bunk wrote:
> On Tue, Sep 16, 2008 at 11:18:08AM +0200, Thomas Bogendoerfer wrote:
> > On Tue, Sep 16, 2008 at 11:39:34AM +0300, Adrian Bunk wrote:
> > > On Mon, Sep 15, 2008 at 03:11:25PM -0700, David Miller wrote:
> > > > From: tsbogend@alpha.franken.de (Thomas Bogendoerfer)
> > > > Date: Mon, 15 Sep 2008 23:53:08 +0200
> > > > 
> > > > > On Mon, Sep 15, 2008 at 02:14:42PM -0700, David Miller wrote:
> > > > > > Most of those changes were complete and utter CRAP.
> > > > > 
> > > > > thank you, but the fix I've sent (de2104x) isn't crap. The bug breaks the 
> > > > > current debian-installer for Cobalt Qube1, when it tries to get an
> > > > > IP address via dhcp. 
> > > > 
> > > > And why is this bug that has been there for YEARS is appropriate
> > > > to fix outside of the merge window?
> > > >...
> > > 
> > > Such a fix is even suitable for -stable.
> > 
> > that was my feeling as well, but if David wants to see it in the next
> > merge window, it's his decision. It's not a important fix as the user
> > base is obviuosly pretty small. And I didn't know about that bug, when
> > the merge windows was open, so I couldn't fix it "in time".
> 
> And if it goes in during the next merge window it can immediately go 
> into 2.6.27.1 (and even 2.6.26.y if it's still maintained), since the 
> fix fulfills Documentation/stable_kernel_rules.txt .
> 
> That doesn't make sense.

Note that my emails are not meant against David personally - he just 
seems to have gotten from pushing too much to pushing too few, with
such illogical results.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

