From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: icmp_unreachable uses wrong ip
Date: Tue, 3 May 2005 11:22:44 +0200
Message-ID: <20050503092244.GA8864@xi.wantstofly.org>
References: <1115040079.5620.11.camel@jeroens.office.netland.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "J. Simonetti" <jeroens@office.netland.nl>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <1115040079.5620.11.camel@jeroens.office.netland.nl>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, May 02, 2005 at 03:21:19PM +0200, J. Simonetti wrote:

> I've recently come to notice that traceroutes through a linux router use
> the wrong ip (ip of exitting interface) wich should actually be the ip
> of the incomming interface.
> 
> I've found a trivial patch (attached) wich resolves this. Perhaps this
> is something to include (or have a sysctl to toggle this behaviour). I
> unfortunately have no knowledge of programming, so the sysctl option
> would have te be done by a volunteer.

For what it's worth, I would love to see something like this in.
In the presence of asymmetric routing, the way linux routers show
up on traceroutes has always been slightly confusing to me.

(I know, "Every other router vendor out there does it this way."
is not a good reason for doing it the same way.)


--L
