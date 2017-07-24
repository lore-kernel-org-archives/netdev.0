From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] rxrpc: Rearrange headers
Date: Mon, 24 Jul 2017 16:17:34 -0700 (PDT)
Message-ID: <20170724.161734.314010681276806847.davem@davemloft.net>
References: <150066178283.18902.5185801865257802317.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <150066178283.18902.5185801865257802317.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Fri, 21 Jul 2017 19:29:42 +0100

> 
> Here's a pair of patches that rearrange some of the AF_RXRPC header files
> that are outside of the net/rxrpc/ directory:
> 
>  (1) The bits userspace need are moved to uapi/linux/rxrpc.h.  [Should this
>      be af_rxrpc.h instead, I wonder - but there doesn't seem to be
>      precedent for that in the other net UAPI headers.]
> 
>  (2) For the most part, the contents of rxrpc/packet.h are no longer used
>      outside of the AF_RXRPC module, so move them to net/rxrpc/protocol.h
>      with the exception of the standard abort codes which are exposed to
>      userspace when an abort occurs and the security index values which are
>      needed when constructing keys.
> 
> The patches can be found here also:
> 
> 	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite
> 
> Tagged thusly:
> 
> 	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
> 	rxrpc-rewrite-20170721

Pulled, thanks David.
