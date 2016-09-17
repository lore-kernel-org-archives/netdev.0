From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rxrpc: Make IPv6 support conditional on
 CONFIG_IPV6
Date: Sat, 17 Sep 2016 03:59:17 -0400 (EDT)
Message-ID: <20160917.035917.679463719571971081.davem@davemloft.net>
References: <147409356125.30214.18028040340873709660.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56282 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753911AbcIQH7Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2016 03:59:24 -0400
In-Reply-To: <147409356125.30214.18028040340873709660.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Howells <dhowells@redhat.com>
Date: Sat, 17 Sep 2016 07:26:01 +0100

> Add CONFIG_AF_RXRPC_IPV6 and make the IPv6 support code conditional on it.
> This is then made conditional on CONFIG_IPV6.
> 
> Without this, the following can be seen:
> 
>    net/built-in.o: In function `rxrpc_init_peer':
>>> peer_object.c:(.text+0x18c3c8): undefined reference to `ip6_route_output_flags'
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: David Howells <dhowells@redhat.com>

Applied.
