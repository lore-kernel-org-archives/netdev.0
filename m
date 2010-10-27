From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tunnels: add __rcu annotations
Date: Wed, 27 Oct 2010 11:22:27 -0700 (PDT)
Message-ID: <20101027.112227.179923691.davem@davemloft.net>
References: <1288076486.3296.85.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35689
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754610Ab0J0SWE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 14:22:04 -0400
In-Reply-To: <1288076486.3296.85.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 26 Oct 2010 09:01:26 +0200

> Add __rcu annotations to :
>         (struct ip_tunnel)->prl
>         (struct ip_tunnel_prl_entry)->next
>         (struct xfrm_tunnel)->next
> 	struct xfrm_tunnel *tunnel4_handlers
> 	struct xfrm_tunnel *tunnel64_handlers
> 
> And use appropriate rcu primitives to reduce sparse warnings if
> CONFIG_SPARSE_RCU_POINTER=y
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
