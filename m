From: josh@joshtriplett.org
Subject: Re: [PATCH 08/24] net, diet: Make TCP metrics optional
Date: Tue, 6 May 2014 10:55:47 -0700
Message-ID: <20140506175547.GE20776@cloud>
References: <20140506155703.GA20391@cloud>
 <20140506.115941.428706504757835279.davem@davemloft.net>
 <20140506164108.GA20536@cloud>
 <20140506.131643.994244006906866938.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tom.zanussi@linux.intel.com,
	ak@linux.intel.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140506.131643.994244006906866938.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 06, 2014 at 01:16:43PM -0400, David Miller wrote:
> From: josh@joshtriplett.org
> Date: Tue, 6 May 2014 09:41:08 -0700
> 
> > Every KB of RAM costs real money and SoC die area (for eDRAM/eSRAM).
> 
> Another poster commented that 16MB of DRAM would be cheaper than
> the 2MB of ram you have on these boards, probably one that fits
> your size profile is available as well.
> 
> 2MB is just a rediculous restriction.

Embedded systems experts disagree with you there; there *are* systems
where the most cost-efficient approach is a few MB (or a few hundred KB)
of non-discrete memory.  We're not talking about socketed memory or even
soldered-down memory; we're talking about entire systems that fit on a
small SoC die.  The space not used by that extra RAM may well be better
spent on CPU optimizations, or some other integrated component.

Such boards will be built, and many of them will run Linux, despite your
incredulity.  When you're building millions of a board, it's well worth
optimizing software to eliminate components from the bill of materials.

And even on a system with 4MB or 8MB or 16MB of memory, a few hundred
extra KB used by the kernel and unavailable to userspace *matters*; that
could be the difference between fitting in 8MB or 16MB.

> And last time I checked Linux wasn't a special purpose operating
> system

No, it's an extremely general-purpose operating system, supporting
enough customization to run on everything from supercomputers to some
embedded systems.  And that's partly because people who care about those
systems submit patches to make Linux scale.  You take patches to scale
*up* to absurdly huge systems; what makes it so painful to take patches
to scale *down*?

> , but lucky for you I hear there are lots of those around.

Why would I want to run one of those when I can run Linux?

- Josh Triplett
