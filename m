From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] slub: fix slab_pad_check()
Date: Wed, 9 Sep 2009 08:09:45 -0700
Message-ID: <20090909150945.GB6749@linux.vnet.ibm.com>
References: <20090903231757.GP6761@linux.vnet.ibm.com> <alpine.DEB.1.10.0909041140040.9781@V090114053VZO-1> <20090904204335.GG6751@linux.vnet.ibm.com> <alpine.DEB.1.10.0909081555410.26382@V090114053VZO-1> <20090908222036.GM6753@linux.vnet.ibm.com> <alpine.DEB.1.10.0909081839090.7733@V090114053VZO-1> <20090908225937.GO6753@linux.vnet.ibm.com> <alpine.DEB.1.10.0909091002440.28070@V090114053VZO-1> <20090909144238.GA6749@linux.vnet.ibm.com> <alpine.DEB.1.10.0909091052380.28070@V090114053VZO-1>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Zdenek Kabelac <zdenek.kabelac@gmail.com>,
	Patrick McHardy <kaber@trash.net>, Robin Holt <holt@sgi.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Jesper Dangaard Brouer <hawk@comx.dk>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	dhowells@redhat.com, lethal@linux-sh.org, kernel@wantstofly.org,
	mpm@selenic.com
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0909091052380.28070@V090114053VZO-1>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 09, 2009 at 10:53:22AM -0400, Christoph Lameter wrote:
> On Wed, 9 Sep 2009, Paul E. McKenney wrote:
> 
> > If the embedded guys are OK with an additional pointer in the slab data
> > structure, I have no objection to this approach.  I am assuming that we
> > would use the usual ops-style structure full of pointers to functions
> > in order to avoid a pair of extra pointers.
> 
> This would also allow us to get rid of the ctor pointer in
> kmem_cache_create(). We can put it into the same structure.

Sounds good -- that would result in no increase in size.  Could even
add a dtor if people want it.  ;-)  (Sorry, couldn't resist...)

						Thanx, Paul
