From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rxrpc: Support network namespacing
Date: Thu, 25 May 2017 13:20:14 -0400 (EDT)
Message-ID: <20170525.132014.914695127659161968.davem@davemloft.net>
References: <149564175249.12289.12304563996697291080.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59610 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1031883AbdEYRUQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 13:20:16 -0400
In-Reply-To: <149564175249.12289.12304563996697291080.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Howells <dhowells@redhat.com>
Date: Wed, 24 May 2017 17:02:32 +0100

> Support network namespacing in AF_RXRPC with the following changes:
> 
>  (1) All the local endpoint, peer and call lists, locks, counters, etc. are
>      moved into the per-namespace record.
> 
>  (2) All the connection tracking is moved into the per-namespace record
>      with the exception of the client connection ID tree, which is kept
>      global so that connection IDs are kept unique per-machine.
> 
>  (3) Each namespace gets its own epoch.  This allows each network namespace
>      to pretend to be a separate client machine.
> 
>  (4) The /proc/net/rxrpc_xxx files are now called /proc/net/rxrpc/xxx and
>      the contents reflect the namespace.
> 
> fs/afs/ should be okay with this patch as it explicitly requires the current
> net namespace to be init_net to permit a mount to proceed at the moment.  It
> will, however, need updating so that cells, IP addresses and DNS records are
> per-namespace also.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>

Applied.
