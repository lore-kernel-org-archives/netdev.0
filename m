From: josh@joshtriplett.org
Subject: Re: [PATCH 08/24] net, diet: Make TCP metrics optional
Date: Tue, 6 May 2014 09:45:46 -0700
Message-ID: <20140506164546.GB20536@cloud>
References: <1399328773-6531-9-git-send-email-andi@firstfloor.org>
 <20140505.231229.136734008603421707.davem@davemloft.net>
 <20140506032114.GP2382@two.firstfloor.org>
 <20140505.232327.578134514220748085.davem@davemloft.net>
 <20140506155703.GA20391@cloud>
 <1399394359.15399.20.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, andi@firstfloor.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tom.zanussi@linux.intel.com, ak@linux.intel.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1399394359.15399.20.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 06, 2014 at 09:39:19AM -0700, Eric Dumazet wrote:
> On Tue, 2014-05-06 at 08:57 -0700, josh@joshtriplett.org wrote:
> 
> > A NAK isn't going to cut it, here; tiny Linux systems are going to
> > exist, and they shouldn't have to maintain a long-term out-of-tree fork
> > or use crazy things like LWIP.
> 
> What's wrong with user space implementations of networking stacks ?

What's wrong with the kernel implementation?

> For many usages, it can bring 10 times the performance of having user
> application and kernel sockets.

Sounds like we have some optimization to do, then; there's no
fundamental unfixable reason for that delta.

> In any cases, we do not model kernel implementations to 'compete' with
> user space.
> 
> We simply can not compete with user space, as a programmer is free to
> keep what he really wants/needs.

The kernel can do the same.  Consider the idea of analyzing a set of
userspace programs, determining what kernel functionality they do and
don't need, feeding that information into the kernel build process, and
automatically dropping unused bits of the kernel.

Ideally, that kind of process would support eliminating kernel config
options that just select userspace-visible interfaces, leaving only the
kernel config options that change how those interfaces behave
(size/performance/feature tradeoffs).

- Josh Triplett
