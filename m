From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [07/08] [TCP] Fix BIC congestion avoidance algorithm error
Date: Tue, 5 Apr 2005 11:32:41 -0700
Message-ID: <20050405113241.3389c9b8@dxpl.pdx.osdl.net>
References: <20050405164539.GA17299@kroah.com>
	<20050405164758.GH17299@kroah.com>
	<20050405182202.GA11979@thunk.org>
	<20050405112608.0b3c07f0.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Theodore Ts'o" <tytso@mit.edu>, gregkh@suse.de,
        linux-kernel@vger.kernel.org, stable@kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050405112608.0b3c07f0.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 5 Apr 2005 11:26:08 -0700
"David S. Miller" <davem@davemloft.net> wrote:

> On Tue, 5 Apr 2005 14:22:02 -0400
> Theodore Ts'o <tytso@mit.edu> wrote:
> 
> > If the congestion control alogirthm is "Reno-like", what is
> > user-visible impact to users?  There are OS's out there with TCP/IP
> > stacks that are still using Reno, aren't there?  
> 
> An incorrect implementation of any congestion control algorithm
> has ramifications not considered when the congestion control
> author verified the design of his algorithm.
> 
> This has a large impact on every user on the internet, not just
> Linux machines.
> 
> Perhaps on a microscopic scale "this" part of the BIC algorithm
> was just behaving Reno-like due to the bug, but what implications
> does that error have as applied to the other heuristics in BIC?
> This is what I'm talking about.  BIC operates in several modes,
> one of which is a pseudo binary search mode, and another is a
> less aggressive slower increase mode.

> Therefore I think fixes to congestion control algorithms which
> are enabled by default always should take a high priority in
> the stable kernels.

Also, hopefully distro vendors will pick up 2.6.11.X fixes and update their customers.
