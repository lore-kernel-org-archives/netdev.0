From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH] remove sdla from setup.c
Date: Thu, 29 May 2003 12:36:25 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030529153625.GP24054@conectiva.com.br>
References: <20030528110658.GA26411@lst.de> <20030529.025749.59658664.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hch@lst.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030529.025749.59658664.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Thu, May 29, 2003 at 02:57:49AM -0700, David S. Miller escreveu:
>    From: Christoph Hellwig <hch@lst.de>
>    Date: Wed, 28 May 2003 13:06:58 +0200
> 
>    sdla had calls from both Space.c and setup.c.  Leave the Space.c one
>    alone as per previous discussion but move over the setup.c one to
>    initcalls.  (and remove the prototype for a third one from setup.c!)
>    
> Looks ok, applied.
> 
> Some of this wan driver stuff is so crappy :(

Crappy? You are being nice...

What about this:

void lock_adapter_irq(spinlock_t *lock, unsigned long *smp_flags)
{
        spin_lock_irqsave(lock, *smp_flags);
}

Why the hell do we need a bogus wrapper for something so standard?

:-(

- Arnaldo
