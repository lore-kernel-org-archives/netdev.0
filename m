From: "David S. Miller" <davem@davemloft.net>
Subject: Re: issue with new TCP TSO stuff
Date: Thu, 12 May 2005 13:03:41 -0700 (PDT)
Message-ID: <20050512.130341.82102354.davem@davemloft.net>
References: <m1sm0sttvy.fsf@muc.de>
	<20050512.122657.50069962.davem@davemloft.net>
	<20050512200251.GA72662@muc.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ak@muc.de
In-Reply-To: <20050512200251.GA72662@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@muc.de>
Subject: Re: issue with new TCP TSO stuff
Date: 12 May 2005 22:02:51 +0200,Thu, 12 May 2005 22:02:51 +0200

> Sure, but did you verify it was the actual problem? (e.g. with a profiler) 
> If the cache line the atomic operation is done on is EXCLUSIVE to the
> CPU then it should not take *that* long to do the atomic operations.

Such issues cannot be measured like that, they tend to make
other operations slower by inducing cache misses elsewhere.

I used my brain to analyze this slowdown, instead of the
computer, I'm sorry if that disturbs you :-)
