From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] [RXRPC]: do not unlock unheld spinlock in rxrpc_connect_exclusive()
Date: Wed, 18 Dec 2013 16:10:55 +0000
Message-ID: <29861.1387383055@warthog.procyon.org.uk>
References: <20131217.151656.2218064732946772466.davem@davemloft.net> <1386975369-30837-1-git-send-email-khoroshilov@ispras.ru>
Cc: dhowells@redhat.com, khoroshilov@ispras.ru,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131217.151656.2218064732946772466.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:

> From: Alexey Khoroshilov <khoroshilov@ispras.ru>
> Date: Sat, 14 Dec 2013 02:56:09 +0400
> 
> > +		_net("CONNECT EXCL old %d on TRANS %d",
> > +		     conn->debug_id, conn->trans->debug_id);
> 
> Please do not add more of these ad-hoc kernel log tracing entries.

Why not?  They're useful for debugging and they give me more control than
plain printk().

I presume you want all the debugging statements in net/rxrpc/ changing to
something else - but what?

David
