From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [git patches] net driver fixes
Date: Tue, 16 Sep 2008 18:43:42 +0300
Message-ID: <20080916154342.GD1400@cs181140183.pp.htv.fi>
References: <20080916104811.GC7397@cs181140183.pp.htv.fi> <20080916114305.GB10965@ff.dom.local> <20080916121528.GD7397@cs181140183.pp.htv.fi> <20080916135408.GB13388@mit.edu> <20080916070241.3e8d5202@infradead.org> <20080916143408.GA1400@cs181140183.pp.htv.fi> <20080916074802.200c8a43@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Theodore Tso <tytso@mit.edu>, Jarek Poplawski <jarkao2@gmail.com>,
	Thomas Bogendoerfer <tsbogend@alpha.franken.de>,
	David Miller <davem@davemloft.net>, jeff@garzik.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.pp.htv.fi ([213.243.153.38]:48398 "EHLO smtp4.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752064AbYIPPoA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Sep 2008 11:44:00 -0400
Content-Disposition: inline
In-Reply-To: <20080916074802.200c8a43@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 16, 2008 at 07:48:02AM -0700, Arjan van de Ven wrote:
> On Tue, 16 Sep 2008 17:34:10 +0300
> Adrian Bunk <bunk@kernel.org> wrote:
>...
> > And the same also e.g. goes for bugs where your machine is completely 
> > dead (no SysRq possible) with nothing in the logs.
> 
> that's being worked on, by storing the crash data in some non-volatile
> piece of memory

The kerneloops list is helpful, and improving it is great, but it will 
never be able to cover 100% of all problems on 100% of all computers.

> > The kerneloops lists are quite valuable, but they can never cover all 
> > classes of fatal bugs.
> 
> if you want perfection, you're not going to get it.
> 
> "Perfect is the enemy of good"
> 
> If you want to help make things better (as opposed to perfect), you're
> very welcome to help out, be it with suggestions on how to improve
> or with actual code. 

You miss my point:

We agree that the kerneloops list is not perfect.

And usually the bugs with a trace that go into the list are the
ones that are easier to debug and fix, while the others might be
much harder to debug.

If one takes Linus' "simple rule of thumb" literally then a hard to 
debug bug without any messages anywhere mustn't be fixed outside of
a merge window. This literal reading is what doesn't make sense.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

