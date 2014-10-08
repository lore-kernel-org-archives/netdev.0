From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] i40e: skb->xmit_more support
Date: Wed, 08 Oct 2014 16:04:02 -0400 (EDT)
Message-ID: <20141008.160402.1638104624060171763.davem@davemloft.net>
References: <1412713823.11091.166.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dborkman@redhat.com,
	jeffrey.t.kirsher@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57223 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753236AbaJHUEE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 16:04:04 -0400
In-Reply-To: <1412713823.11091.166.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 07 Oct 2014 13:30:23 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Support skb->xmit_more in i40e is straightforward : we need to move
> around i40e_maybe_stop_tx() call to correctly test netif_xmit_stopped()
> before taking the decision to not kick the NIC.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks everyone.
