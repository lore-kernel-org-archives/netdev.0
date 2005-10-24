From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: Request for an ARPHRD_
Date: Tue, 25 Oct 2005 00:22:23 +0200
Message-ID: <20051024222222.GA11005@xi.wantstofly.org>
References: <200510240255.28416.daniele@orlandi.com> <200510242333.05366.daniele@orlandi.com> <20051024215140.GA10872@xi.wantstofly.org> <200510250008.10409.daniele@orlandi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Daniele Orlandi <daniele@orlandi.com>
Content-Disposition: inline
In-Reply-To: <200510250008.10409.daniele@orlandi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Oct 25, 2005 at 12:08:09AM +0200, Daniele Orlandi wrote:

> > First get your code in the kernel, then submit the patch to libpcap.
> 
> Hopefully I will but currently vISDN is not mature enough to be
> evaluated for kernel inclusion.
> 
> I would like to keep it out of the tree while it matures, however I
> would also like to avoid potential constants clashes with outher/future
> code.
> 
> You may see the constants allocation as the first step to include that
> code in the kernel.

Your code might never end up in the kernel at all, for example if you
ever lose interest in it.  The situation that we'd like to avoid is
ending up with reserved constants for code that was never submitted
upstream at all.


cheers,
Lennert
