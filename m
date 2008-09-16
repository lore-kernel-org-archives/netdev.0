From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [git patches] net driver fixes
Date: Tue, 16 Sep 2008 17:46:38 +0300
Message-ID: <20080916144638.GB1400@cs181140183.pp.htv.fi>
References: <20080916104811.GC7397@cs181140183.pp.htv.fi> <20080916114305.GB10965@ff.dom.local> <20080916121528.GD7397@cs181140183.pp.htv.fi> <20080916135408.GB13388@mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Theodore Tso <tytso@mit.edu>, Jarek Poplawski <jarkao2@gmail.com>,
	Thomas Bogendoerfer <tsbogend@alpha.franken.de>,
	David Miller <davem@davemloft.net>, jeff@garzik.org,
	netdev@vger.ke
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6.pp.htv.fi ([213.243.153.40]:41992 "EHLO smtp6.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752624AbYIPOq5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Sep 2008 10:46:57 -0400
Content-Disposition: inline
In-Reply-To: <20080916135408.GB13388@mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 16, 2008 at 09:54:08AM -0400, Theodore Tso wrote:
> On Tue, Sep 16, 2008 at 03:15:28PM +0300, Adrian Bunk wrote:
> > 
> > More seriously, there's a difference between Linus' "another random 
> > improvement" and an "is even suitable for -stable".
> > 
> > I'm not reading Linus' (Cc'ed) statement the way that a patch that is 
> > appropriate for 2.6.27.1 is not appropriate for -rc now.
> 
> Well, remember that patches that get published for -stable do have to
> go through an extra review process.  It's not true that any "obviously
> correct" bug fix gets automatically published in -stable.  Sometimes
> bug fixes do get rejected for -stable because they are too risky, or
> require more time for testing in the -rc series before they are deemed
> suitable for -stable.
>...
> If it's a really important bug, and it affects a huge number of users,
> or it's really bad security bug, the reality is that exceptions will
> be made to the rules.  But exceptions need to remain exceptions for
> extraordinary situations, not everyday occurrences.  And of course, if
> the bug does affect a huge number of users, someone should be asking
> the question why it wasn't detected sooner, say before the last merge
> window --- and to ask the question how many users is this bug really
> going to affect anyway?

Among the patches David rejected based on what Linus said was
Thomas' patch [1].

It is not a "really important bug" and does not affect "huge number
of users".

But it passes Documentation/stable_kernel_rules.txt, and can we agree 
that if it gets submitted for 2.6.27.1 it will likely pass review and 
get applied?

That's the kind of patches I'm talking about.

> At least, that's my take on things,
> 
> 						- Ted

cu
Adrian

[1] http://article.gmane.org/gmane.linux.network/105810

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

