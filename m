From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Move fib_alias out of fib_hash.c
Date: Wed, 29 Sep 2004 14:27:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040929142750.27b35952.davem@davemloft.net>
References: <20040928214722.11aef8e0.davem@davemloft.net>
	<16730.53965.503605.943263@robur.slu.se>
	<20040929125359.12a00ba7.davem@davemloft.net>
	<1096492842.2344.57.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Steven Blake <slblake@petri-meat.com>
In-Reply-To: <1096492842.2344.57.camel@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 29 Sep 2004 17:20:43 -0400
Steven Blake <slblake@petri-meat.com> wrote:

> > It can also
> > be the case that the longest matching prefix entry has no matching
> > TOS key, whereas a shorter prefix does.
> 
> No routing protocols are distributing TOS-specific routes, and there is
> no prospect of that feature ever coming back.  Why pay the cost of
> matching TOS on every packet forwarded?

Because once we add functionality to the kernel we can't simply
rip it out.  People do use TOS routing, via static routes or
similar.
