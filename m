From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] rxrpc: Fixes
Date: Fri, 14 Oct 2016 10:45:02 -0400 (EDT)
Message-ID: <20161014.104502.1079192449965835276.davem@davemloft.net>
References: <147637512988.17348.9857198849984467857.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
        dan.carpenter@oracle.com, linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147637512988.17348.9857198849984467857.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Thu, 13 Oct 2016 17:12:09 +0100

> 
> This set of patches contains a bunch of fixes:
> 
>  (1) Fix use of kunmap() after change from kunmap_atomic() within AFS.
> 
>  (2) Don't use of ERR_PTR() with an always zero value.
> 
>  (3) Check the right error when using ip6_route_output().
> 
>  (4) Be consistent about whether call->operation_ID is BE or CPU-E within
>      AFS.
> 
> The patches can be found here also:
> 
> 	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite
> 
> Tagged thusly:
> 
> 	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
> 	rxrpc-rewrite-20161013

Pulled, thanks David.
