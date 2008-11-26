From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Use a percpu_counter for sockets_allocated
Date: Tue, 25 Nov 2008 21:16:51 -0800 (PST)
Message-ID: <20081125.211651.252450470.davem@davemloft.net>
References: <492C80B3.4040209@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56670
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751034AbYKZFQw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 00:16:52 -0500
In-Reply-To: <492C80B3.4040209@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 25 Nov 2008 23:48:19 +0100

> [PATCH] net: Use a percpu_counter for sockets_allocated
> 
> Instead of using one atomic_t per protocol, use a percpu_counter
> for "sockets_allocated", to reduce cache line contention on
> heavy duty network servers. 
> 
> Note : We revert commit (248969ae31e1b3276fc4399d67ce29a5d81e6fd9
> net: af_unix can make unix_nr_socks visbile in /proc),
> since it is not anymore used after sock_prot_inuse_add() addition
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied.
