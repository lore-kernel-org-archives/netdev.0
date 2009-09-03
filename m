From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] slub: fix slab_pad_check() and SLAB_DESTROY_BY_RCU
Date: Thu, 3 Sep 2009 08:00:44 -0700
Message-ID: <20090903150044.GB6761@linux.vnet.ibm.com>
References: <c4e36d110908140233v59421ba6y82192b858210370d@mail.gmail.com> <4A87CE60.4020506@gmail.com> <4A896324.3040104@trash.net> <c4e36d110909021445l5f44183es9e338437dfbbd195@mail.gmail.com> <4A9EEF07.5070800@gmail.com> <c4e36d110909021531v324a9ce2x3ff2c93b7c5a57de@mail.gmail.com> <4A9F1620.2080105@gmail.com> <84144f020909022331x2b275aa5n428f88670e0ae8bc@mail.gmail.com> <4A9F7283.1090306@gmail.com> <alpine.DEB.1.10.0909031244230.27903@V090114053VZO-1>
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
In-Reply-To: <alpine.DEB.1.10.0909031244230.27903@V090114053VZO-1>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 03, 2009 at 12:45:43PM -0500, Christoph Lameter wrote:
> On Thu, 3 Sep 2009, Eric Dumazet wrote:
> 
> > on a SLAB_DESTROY_BY_RCU cache, there is no need to try to optimize this
> > rcu_barrier() call, unless we want superfast reboot/halt sequences...
> 
> I stilll think that the action to quiesce rcu is something that the caller
> of kmem_cache_destroy must take care of.

Why?

							Thanx, Paul

> Could you split this into two patches: One that addresses the poison and
> another that deals with rcu?
> 
