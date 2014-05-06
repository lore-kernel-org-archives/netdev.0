From: josh@joshtriplett.org
Subject: Re: [PATCH 08/24] net, diet: Make TCP metrics optional
Date: Tue, 6 May 2014 13:11:45 -0700
Message-ID: <20140506201145.GC21332@cloud>
References: <20140506164546.GB20536@cloud>
 <20140506.131752.740569380523989782.davem@davemloft.net>
 <20140506172106.GB20776@cloud>
 <20140506.132501.331724703594119414.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, andi@firstfloor.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tom.zanussi@linux.intel.com, ak@linux.intel.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140506.132501.331724703594119414.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 06, 2014 at 01:25:01PM -0400, David Miller wrote:
> From: josh@joshtriplett.org
> Date: Tue, 6 May 2014 10:21:06 -0700
> 
> > On Tue, May 06, 2014 at 01:17:52PM -0400, David Miller wrote:
> >> From: josh@joshtriplett.org
> >> Date: Tue, 6 May 2014 09:45:46 -0700
> >> 
> >> > The kernel can do the same.  Consider the idea of analyzing a set of
> >> > userspace programs, determining what kernel functionality they do and
> >> > don't need, feeding that information into the kernel build process, and
> >> > automatically dropping unused bits of the kernel.
> >> 
> >> Please make sure I'm not on the list of people who see reports for
> >> bugs reported in that setup.
> >> 
> >> Thanks :-)
> > 
> > Fine by me.  Just please allow such a setup to exist. :)
> 
> You see, that's the point I'm trying to make, once it's upstream
> then it's my problem.
> 
> You absolutely must consider the burdon you put upon upstream
> maintainers when you ask for things to be included.

Absolutely.  And Andi and I are both interested in working *with* you to
find a way to run on tiny embedded systems *without* necessarily
introducing excessive proliferation of configuration options or
unnecessarily increasing your support burden.

For instance, it's easy enough to key some options off of CONFIG_NR_CPUS
(such as data structure sizes), or introduce a big config switch
(CONFIG_NETWORK_FULL=n or similar) that controls all of these cases
rather than having option for each.  That would not be hard to supply in
a v2 of this patch series.

And if you're asking for someone to help pay attention to bug reports so
you don't have to, that's reasonable as well; just like you probably
have a stock response for "that's a crazy distro kernel, ask them about
it and not me", you could have a stock response for "that kernel has the
crazy embedded option turned on, ask the embedded people about it and
not me".  It doesn't just have to be *your* problem alone.

There's a stigma rightfully attached to out-of-tree patches, which
roughly amounts to "people ought to submit patches upstream, we
shouldn't have to support or care about out-of-tree patches".  But that
only works if the responses to patch submissions are either "No, because
you need to fix X, Y, and Z", or "No, because your use case is better
served by this existing mechanism already in the kernel", rather than
"No, your use case is not valid".

- Josh Triplett
