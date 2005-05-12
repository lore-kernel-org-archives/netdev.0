From: Andi Kleen <ak@muc.de>
Subject: Re: issue with new TCP TSO stuff
Date: 12 May 2005 22:26:29 +0200
Message-ID: <20050512202629.GB72662@muc.de>
References: <m1sm0sttvy.fsf@muc.de> <20050512.122657.50069962.davem@davemloft.net> <20050512200251.GA72662@muc.de> <20050512.130341.82102354.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
Date: Thu, 12 May 2005 22:26:29 +0200
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050512.130341.82102354.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, May 12, 2005 at 01:03:41PM -0700, David S. Miller wrote:
> From: Andi Kleen <ak@muc.de>
> Subject: Re: issue with new TCP TSO stuff
> Date: 12 May 2005 22:02:51 +0200,Thu, 12 May 2005 22:02:51 +0200
> 
> > Sure, but did you verify it was the actual problem? (e.g. with a profiler) 
> > If the cache line the atomic operation is done on is EXCLUSIVE to the
> > CPU then it should not take *that* long to do the atomic operations.
> 
> Such issues cannot be measured like that, they tend to make
> other operations slower by inducing cache misses elsewhere.

Atomic operations, especially with cache misses, normally show in a fine 
grained profile. They also don't cause additional cache misses over
non atomic writes.

> I used my brain to analyze this slowdown, instead of the
> computer, I'm sorry if that disturbs you :-)

What disturbs me is your conclusion :)

-Andi 
