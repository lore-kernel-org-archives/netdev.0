From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] i40e: skb->xmit_more support
Date: Tue, 07 Oct 2014 16:37:30 -0400 (EDT)
Message-ID: <20141007.163730.2221137596344407031.davem@davemloft.net>
References: <1412713823.11091.166.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dborkman@redhat.com,
	jeffrey.t.kirsher@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48432 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751407AbaJGUhd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 16:37:33 -0400
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

Intel folks, if I could get a quick review of this that would be great.

Thanks.
