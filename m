From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET : tcp_memory_pressure and tcp_socket
 are__read_mostly candidates
Date: Tue, 27 Mar 2007 13:58:52 -0700 (PDT)
Message-ID: <20070327.135852.69409418.davem@davemloft.net>
References: <20070327152513.6b82d296.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52742
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S934166AbXC0U6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 16:58:53 -0400
In-Reply-To: <20070327152513.6b82d296.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 27 Mar 2007 15:25:13 +0200

> 
> tcp_memory_pressure and tcp_socket currently share a cache line with tcp_memory_allocated, tcp_sockets_allocated.
> (Very hot cache line)
> It makes sense to declare these variables as __read_mostly, to avoid false sharing on SMP.
> 
> ffffffff8081d9c0 B tcp_orphan_count
> ffffffff8081d9c4 B tcp_memory_allocated
> ffffffff8081d9c8 B tcp_sockets_allocated
> ffffffff8081d9cc B tcp_memory_pressure
> ffffffff8081d9d0 b tcp_md5sig_users
> ffffffff8081d9d8 b tcp_md5sig_pool
> ffffffff8081d9e0 b warntime.31570
> ffffffff8081d9e8 b tcp_socket
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Thanks for spotting this Eric, patch applied, thanks!
