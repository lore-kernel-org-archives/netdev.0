From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Advice needed on IP-over-InfiniBand driver
Date: Mon, 27 Sep 2004 21:52:44 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927215244.697aaa02.davem@davemloft.net>
References: <52fz5esxx6.fsf@topspin.com>
	<20040919140133.60ea3fb3.davem@davemloft.net>
	<52r7onc8ev.fsf@topspin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Roland Dreier <roland@topspin.com>
In-Reply-To: <52r7onc8ev.fsf@topspin.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 27 Sep 2004 21:41:12 -0700
Roland Dreier <roland@topspin.com> wrote:

> I've been mulling over the previous advice I got and reading over the
> networking code, and I hope I have some more intelligent questions
> now.  It seems I really have two somewhat independent issues to
> resolve with respect to IP-over-IB address resolution:
> 
>  - IPoIB adds a second InfiniBand-specific path record lookup after
>    the normal ARP/ND lookup.  I think I have a handle on how this can
>    be added to net/ipv4/arp.c.

I think you might learn something by having a look at
what net/atm/clip.c is doing, it creates it's own neighbour
layer for CLIP ATM neighbours.  It is in a similar boat to
your IPoIB stuff.
