From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH -tip 0/3] expedited "big hammer" RCU grace periods
Date: Thu, 25 Jun 2009 08:27:36 -0700
Message-ID: <20090625152736.GC6761@linux.vnet.ibm.com>
References: <20090624164535.GA13334@linux.vnet.ibm.com> <20090624180303.GE7576@elte.hu> <20090624184423.GK6779@linux.vnet.ibm.com> <20090625095953.GC29980@elte.hu>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, davem@davemloft.net,
	dada1@cosmosbay.com, zbr@ioremap.net, jeff.chua.linux@gmail.com,
	paulus@samba.org, laijs@cn.fujitsu.com, jengelh@medozas.de,
	r000n@r000n.net, benh@kernel.crashing.org,
	mathieu.desnoyers@polymtl.ca
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090625095953.GC29980@elte.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 25, 2009 at 11:59:53AM +0200, Ingo Molnar wrote:
> 
> * Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> 
> > On Wed, Jun 24, 2009 at 08:03:03PM +0200, Ingo Molnar wrote:
> > > 
> > > * Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> > > 
> > > >  include/linux/rcuclassic.h    |   15 ++-
> > > 
> > > heh, we dont have this file anymore ... as of today, right? :)
> > 
> > Ah, I was assuming that expedited RCU would happen before removal 
> > of Classic RCU.
> 
> Our general preference is to zap code.

Actually worked out nicely in this case -- the fact that Classic RCU
is no longer in -tip meant that I could dump 25% of my test cases for
expedited RCU.  ;-)

I will be posting the updated patch shortly.

> /me stares at:
> 
>   $ git diff --stat -M v2.6.30..v2.6.31-rc1 | tail -1
>   7743 files changed, 782278 insertions(+), 403162 deletions(-)
> 
> /me corrects himself:
> 
> Okay, so the zapping of code is the divine guiding principle we've 
> been following for 15 years. Ending up with a kernel that is 11 
> million lines of code is a small imperfection of mankind and is to 
> be fixed.

;-)  ;-)  ;-)

I guess that if 11 million lines of code is a small imperfection of
mankind, we can only be thankful that we are not tasked with dealing
with the large imperfections.  ;-)

							Thanx, Paul
