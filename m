From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] more const in skbuff
Date: Sat, 20 Sep 2003 00:42:42 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030920004242.2d2a029d.davem@redhat.com>
References: <20030918102709.34211ee5.shemminger@osdl.org>
	<20030918204253.GA43611@gaz.sfgoth.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitchell Blank Jr <mitch@sfgoth.com>
In-Reply-To: <20030918204253.GA43611@gaz.sfgoth.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 18 Sep 2003 13:42:53 -0700
Mitchell Blank Jr <mitch@sfgoth.com> wrote:

> Are you sure that atomic_read() is garaunteed to take a const pointer?
> My understanding is that an arch could in theory take a spinlock (although
> none do currently)
> 
> If it is garaunteed to take a const pointer then please fix the inline in
> include/asm-parisc/atomic.h or your patch will create a lot of warnings on
> that architecture.

I think it is, we decided a bit ago that spinlock based atomics
were a bad idea, and even with that the spinlock atomic_t implementations
do not take the lock in their atomic_read() implementation, they merely
wait to get a sample with the lock clear.

> Other than that this patch is a strict subset of the "small skbuff.[ch]
> tweaks" patch I posted here 2 weeks ago:
>   http://oss.sgi.com/projects/netdev/archive/2003-09/msg00036.html
> Never heard from davem one way or the other on that one.

Stuff often slips through the cracks from time to time, silence
doesn't necessary mean outright rejection so resend.

I'm going to apply Stephen's patch.
