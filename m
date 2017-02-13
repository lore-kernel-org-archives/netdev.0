From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the rcu tree
Date: Mon, 13 Feb 2017 13:21:33 +1100
Message-ID: <20170213132133.3795849e@canb.auug.org.au>
References: <20170119143445.6b65dc8b@canb.auug.org.au>
        <CAJzB8QEdnVG8Gy-WOSu1pWTtkeVWgBzZvGCu0nobW3M-hBhpkw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>, linux-next@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>
To: Paul McKenney <paulmckrcu@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAJzB8QEdnVG8Gy-WOSu1pWTtkeVWgBzZvGCu0nobW3M-hBhpkw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Paul,

On Thu, 19 Jan 2017 13:54:37 -0800 Paul McKenney <paulmckrcu@gmail.com> wrote:
>
> On Wed, Jan 18, 2017 at 7:34 PM, Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> > Hi Paul,
> >
> > After merging the rcu tree, today's linux-next build (x86_64 allmodconfig)
> > failed like this:
> >
> > net/smc/af_smc.c:102:16: error: 'SLAB_DESTROY_BY_RCU' undeclared here (not in a function)
> >   .slab_flags = SLAB_DESTROY_BY_RCU,
> >                 ^
> >
> > Caused by commit
> >
> >   c7a545924ca1 ("mm: Rename SLAB_DESTROY_BY_RCU to SLAB_TYPESAFE_BY_RCU")
> >
> > interacting with commit
> >
> >   ac7138746e14 ("smc: establish new socket family")
> >
> > from the net-next tree.
> >
> > I have applied the following merge fix patch (someone will need to
> > remember to mention this to Linus):  
> 
> Thank you, Stephen!  I expect that there might be a bit more
> bikeshedding on the name, but here is hoping...  :-/

The need for this merge fix patch has gone away today.  Is that a
permanent situation, or will it come back?
-- 
Cheers,
Stephen Rothwell
