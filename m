From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] rxrpc: Preparation for removal of use of
 skbs from AFS
Date: Tue, 30 Aug 2016 22:09:16 -0700 (PDT)
Message-ID: <20160830.220916.828440695872007908.davem@davemloft.net>
References: <147257169706.6391.3116382288289485794.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147257169706.6391.3116382288289485794.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Tue, 30 Aug 2016 16:41:37 +0100

> Here's a set of patches that prepare the way for the removal of the use of
> sk_buffs from fs/afs (they'll be entirely retained within net/rxrpc):
> 
>  (1) Fix a potential NULL-pointer deref in rxrpc_abort_calls().
> 
>  (2) Condense all the terminal call state machine states to a single one
>      plus supplementary info.
> 
>  (3) Add a trace point for rxrpc call usage debugging.
> 
>  (4) Cleanups and missing headers.
> 
>  (5) Provide a way for AFS to ask about a call's peer address without
>      having an sk_buff to query.
> 
>  (6) Use call->peer directly rather than going via call->conn (which might
>      be NULL).
> 
>  (7) Pass struct socket * to various rxrpc kernel interface functions so
>      they can use that directly rather than getting it from the rxrpc_call
>      struct.
 ...
> Tagged thusly:
> 
> 	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
> 	rxrpc-rewrite-20160830-1

Pulled, thanks David.
