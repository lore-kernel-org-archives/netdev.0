From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: use jump_label to shortcut RPS if not
 setup
Date: Thu, 17 Nov 2011 17:06:16 -0500 (EST)
Message-ID: <20111117.170616.1995091290532624972.davem@davemloft.net>
References: <1321535606.2751.35.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33577 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753360Ab1KQWGU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 17:06:20 -0500
In-Reply-To: <1321535606.2751.35.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 17 Nov 2011 14:13:26 +0100

> Most machines dont use RPS/RFS, and pay a fair amount of instructions in
> netif_receive_skb() / netif_rx() / get_rps_cpu() just to discover
> RPS/RFS is not setup.
> 
> Add a jump_label named rps_needed.
> 
> If no device rps_map or global rps_sock_flow_table is setup,
> netif_receive_skb() / netif_rx() do a single instruction instead of many
> ones, including conditional jumps.
> 
> jmp +0    (if CONFIG_JUMP_LABEL=y)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Tom Herbert <therbert@google.com>
> ---
> V2: add netif_rx() optim as well

Applied, thanks.
