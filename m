From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4] kptr_restrict for hiding kernel pointers
Date: Wed, 22 Dec 2010 12:34:44 -0800
Message-ID: <20101222123444.4869b3ed.akpm@linux-foundation.org>
References: <1292708499.10804.89.camel@dan>
	<20101222130349.GB13412@elte.hu>
	<1293023589.9820.186.camel@dan>
	<1293025688.3027.82.camel@edumazet-laptop>
	<20101222162118.GC20358@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Dan Rosenberg <drosenberg@vsecurity.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org, jmorris@namei.org,
	tgraf@infradead.org, eugeneteo@kernel.org, kees.cook@canonical.com,
	davem@davemloft.net, a.p.zijlstra@chello.nl, eparis@parisplace.org,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101222162118.GC20358@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 22 Dec 2010 17:21:18 +0100
Ingo Molnar <mingo@elte.hu> wrote:

> 
> * Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > Le mercredi 22 d__cembre 2010 __ 08:13 -0500, Dan Rosenberg a __crit :
> > > > Hm, why is it off by default? Is there some user-space regression that is caused by 
> > > > this?
> > > > 
> > > > We really want good security measures to be active by default (and to work by 
> > > > default) - they are not worth much if they are not.
> > > > 
> > > 
> > > I agree entirely, but I've received a lot of resistance to these types
> > > of changes in net.  I'm afraid that if it's enabled by default, no one
> > > will actually allow use of the %pK specifier where it should be used.
> > > 
> > 
> > Actually, "net resistance" was against your first patches, using quick
> > and dirty techniques (Should I remind you some of them ?)
> > 
> > Now you have a helper, it should be easier to integrate the changes.
> 
> Great - if the concept itself wasnt objected to then i think we should flip the 
> default to on.
> 

Yes, I'll make that change.  If we get reports of breakage during
2.6.38-rcX then we can reconsider.  But if we leave the feature
disabled, we will never know...  
