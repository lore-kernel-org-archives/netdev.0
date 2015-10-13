From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tun: use sk_fullsock() before reading
 sk->sk_tsflags
Date: Mon, 12 Oct 2015 19:46:21 -0700 (PDT)
Message-ID: <20151012.194621.63549236255212434.davem@davemloft.net>
References: <1444430541.27760.109.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43202 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932132AbbJMCaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 22:30:21 -0400
In-Reply-To: <1444430541.27760.109.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 09 Oct 2015 15:42:21 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> timewait or request sockets are small and do not contain sk->sk_tsflags
> 
> Without this fix, we might read garbage, and crash later in
> 
> __skb_complete_tx_timestamp()
>  -> sock_queue_err_skb()
> 
> (These pseudo sockets do not have an error queue either)
> 
> Fixes: ca6fb0651883 ("tcp: attach SYNACK messages to request sockets instead of listener")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
