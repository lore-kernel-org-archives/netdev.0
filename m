From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] slub: fix slab_pad_check()
Date: Tue, 8 Sep 2009 15:20:36 -0700
Message-ID: <20090908222036.GM6753@linux.vnet.ibm.com>
References: <4A9FCDC6.3060003@gmail.com> <alpine.DEB.1.10.0909031335430.29881@V090114053VZO-1> <4A9FDA72.8060001@gmail.com> <alpine.DEB.1.10.0909031414310.29881@V090114053VZO-1> <4AA00400.1030005@gmail.com> <alpine.DEB.1.10.0909031731540.24199@V090114053VZO-1> <20090903231757.GP6761@linux.vnet.ibm.com> <alpine.DEB.1.10.0909041140040.9781@V090114053VZO-1> <20090904204335.GG6751@linux.vnet.ibm.com> <alpine.DEB.1.10.0909081555410.26382@V090114053VZO-1>
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
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0909081555410.26382@V090114053VZO-1>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 08, 2009 at 03:57:04PM -0400, Christoph Lameter wrote:
> On Fri, 4 Sep 2009, Paul E. McKenney wrote:
> 
> > We have gotten along fine with only SLAB_DESTROY_BY_RCU for almost
> > five years, so I think we are plenty fine with what we have.  So, as
> > you say, "as the need arises".
> 
> These were the glory years where SLAB_DESTROY_BY_RCU was only used for
> anonymous vmas. Now Eric has picked it up for the net subsystem. You may
> see the RCU use proliferate.
> 
> The kmem_cache_destroy rcu barriers did not matter until
> SLAB_DESTROY_BY_RCU spread.

Certainly it is true that increased use of RCU has resulted in new
requirements, which have in turn led to any number of changes over
the years.

Are you saying that people have already asked you for additional
variants of SLAB_DESTROY_BY_RCU?  If so, please don't keep them a secret!
Otherwise, experience indicates that it is best to wait for the new uses,
because they usually aren't quite what one might expect.

							Thanx, Paul
