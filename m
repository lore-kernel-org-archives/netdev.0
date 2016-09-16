From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] rxrpc: Support IPv6
Date: Fri, 16 Sep 2016 01:57:42 -0400 (EDT)
Message-ID: <20160916.015742.1897517375694948164.davem@davemloft.net>
References: <147380649153.30728.6717292274642860064.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147380649153.30728.6717292274642860064.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Tue, 13 Sep 2016 23:41:31 +0100

> 
> Here is a set of patches that add IPv6 support.  They need to be applied on
> top of the just-posted miscellaneous fix patches.  They are:
> 
>  (1) Make autobinding of an unconnected socket work when sendmsg() is
>      called to initiate a client call.
> 
>  (2) Don't specify the protocol when creating the client socket, but rather
>      take the default instead.
> 
>  (3) Use rxrpc_extract_addr_from_skb() in a couple of places that were
>      doing the same thing manually.  This allows the IPv6 address
>      extraction to be done in fewer places.
> 
>  (4) Add IPv6 support.  With this, calls can be made to IPv6 servers from
>      userspace AF_RXRPC programs; AFS, however, can't use IPv6 yet as the
>      RPC calls need to be upgradeable.
 ...
> Tagged thusly:
> 
> 	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
> 	rxrpc-rewrite-20160913-2

Looks good, pulled, thanks.
