From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Reduce netfilter memory use on MP systems
Date: Fri, 4 Feb 2005 18:51:34 +0100
Message-ID: <20050204175134.GD2737@wotan.suse.de>
References: <20050204140900.GD2518@wotan.suse.de>
	<1107538482.1111.6.camel@tux.rsn.bth.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Netfilter-devel <netfilter-devel@lists.netfilter.org>,
	Patrick McHardy <kaber@trash.net>, Andi Kleen <ak@suse.de>
To: Martin Josefsson <gandalf@wlug.westbo.se>
Content-Disposition: inline
In-Reply-To: <1107538482.1111.6.camel@tux.rsn.bth.se>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

> > And in general it saves a lot of memory.
> 
> Patrick, could you apply and submit this patch to Davem? Or if Davem
> applies it himself. It's pretty obvious and would help small SMP
> machines with distribution kernels and/or strange admins.

The main motivation is actually not to save the memory (that's just
a useful side effect), but increase the max limit on 64bit systems.
Fixing it fully will require fixing vmalloc of course, but it already
help. Without it you can't get more than ~3800 rules
on a 64bit system with NR_CPUS==128 and 128 byte cache lines.

-Andi
