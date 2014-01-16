From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: eth_type_trans() should use
 skb_header_pointer()
Date: Thu, 16 Jan 2014 15:30:44 -0800 (PST)
Message-ID: <20140116.153044.1318855011954380596.davem@davemloft.net>
References: <1389743541.31367.279.camel@edumazet-glaptop2.roam.corp.google.com>
	<1389745269.2025.228.camel@bwh-desktop.uk.level5networks.com>
	<1389913411.31367.430.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54873 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751915AbaAPXap (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 18:30:45 -0500
In-Reply-To: <1389913411.31367.430.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 16 Jan 2014 15:03:31 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> eth_type_trans() can read uninitialized memory as drivers
> do not necessarily pull more than 14 bytes in skb->head before
> calling it.
> 
> As David suggested, we can use skb_header_pointer() to
> fix this without breaking some drivers that might not expect
> eth_type_trans() pulling 2 additional bytes.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Ben Hutchings <bhutchings@solarflare.com>
> ---
> Since this bug is very old, I cooked the patch on net-next

Applied, thanks a lot Eric.
