From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: linux-next: build failure after merge of the rcu tree
Date: Sun, 12 Feb 2017 20:37:48 -0800
Message-ID: <20170213043748.GA30506@linux.vnet.ibm.com>
References: <20170119143445.6b65dc8b@canb.auug.org.au>
 <CAJzB8QEdnVG8Gy-WOSu1pWTtkeVWgBzZvGCu0nobW3M-hBhpkw@mail.gmail.com>
 <20170213132133.3795849e@canb.auug.org.au>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul McKenney <paulmckrcu@gmail.com>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>, linux-next@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170213132133.3795849e@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 13, 2017 at 01:21:33PM +1100, Stephen Rothwell wrote:
> Hi Paul,
> 
> On Thu, 19 Jan 2017 13:54:37 -0800 Paul McKenney <paulmckrcu@gmail.com> wrote:
> >
> > On Wed, Jan 18, 2017 at 7:34 PM, Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> > > Hi Paul,
> > >
> > > After merging the rcu tree, today's linux-next build (x86_64 allmodconfig)
> > > failed like this:
> > >
> > > net/smc/af_smc.c:102:16: error: 'SLAB_DESTROY_BY_RCU' undeclared here (not in a function)
> > >   .slab_flags = SLAB_DESTROY_BY_RCU,
> > >                 ^
> > >
> > > Caused by commit
> > >
> > >   c7a545924ca1 ("mm: Rename SLAB_DESTROY_BY_RCU to SLAB_TYPESAFE_BY_RCU")
> > >
> > > interacting with commit
> > >
> > >   ac7138746e14 ("smc: establish new socket family")
> > >
> > > from the net-next tree.
> > >
> > > I have applied the following merge fix patch (someone will need to
> > > remember to mention this to Linus):  
> > 
> > Thank you, Stephen!  I expect that there might be a bit more
> > bikeshedding on the name, but here is hoping...  :-/
> 
> The need for this merge fix patch has gone away today.  Is that a
> permanent situation, or will it come back?

I chickened out on that commit for this merge window, so it will come
back at -rc1.  But I will cover that when I rebase to -rc1.

							Thanx, Paul
