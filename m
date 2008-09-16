From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [git patches] net driver fixes
Date: Tue, 16 Sep 2008 17:34:10 +0300
Message-ID: <20080916143408.GA1400@cs181140183.pp.htv.fi>
References: <20080916104811.GC7397@cs181140183.pp.htv.fi> <20080916114305.GB10965@ff.dom.local> <20080916121528.GD7397@cs181140183.pp.htv.fi> <20080916135408.GB13388@mit.edu> <20080916070241.3e8d5202@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Theodore Tso <tytso@mit.edu>, Jarek Poplawski <jarkao2@gmail.com>,
	Thomas Bogendoerfer <tsbogend@alpha.franken.de>,
	David Miller <davem@davemloft.net>, jeff@garzik.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5.pp.htv.fi ([213.243.153.39]:40139 "EHLO smtp5.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752368AbYIPOe3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Sep 2008 10:34:29 -0400
Content-Disposition: inline
In-Reply-To: <20080916070241.3e8d5202@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 16, 2008 at 07:02:41AM -0700, Arjan van de Ven wrote:
> On Tue, 16 Sep 2008 09:54:08 -0400
> Theodore Tso <tytso@mit.edu> wrote:
> 
> > If it's a really important bug, and it affects a huge number of users,
> > or it's really bad security bug, the reality is that exceptions will
> > be made to the rules.  But exceptions need to remain exceptions for
> > extraordinary situations, not everyday occurrences.  And of course, if
> > the bug does affect a huge number of users, someone should be asking
> > the question why it wasn't detected sooner, say before the last merge
> > window --- and to ask the question how many users is this bug really
> > going to affect anyway?
> > 
> > At least, that's my take on things,
> > 
> 
> also note that Linus said "regression or on the kerneloops list";
> if it has any kind of backtrace, it'll be there if it's a common
> problem that hits many users.

Thomas' patch [1] will fixes a bug of a kind that will likely never 
make it to your list.

And the same also e.g. goes for bugs where your machine is completely 
dead (no SysRq possible) with nothing in the logs.

The kerneloops lists are quite valuable, but they can never cover all 
classes of fatal bugs.

cu
Adrian

[1] http://article.gmane.org/gmane.linux.network/105810

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

