From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: add __rcu annotations to ip_ra_chain
Date: Mon, 25 Oct 2010 14:19:39 -0700 (PDT)
Message-ID: <20101025.141939.116366029.davem@davemloft.net>
References: <1288013564.2826.123.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48807
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756097Ab0JYVTQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 17:19:16 -0400
In-Reply-To: <1288013564.2826.123.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 25 Oct 2010 15:32:44 +0200

> Add __rcu annotations to :
>         (struct ip_ra_chain)->next
> 	struct ip_ra_chain *ip_ra_chain;
> 
> And use appropriate rcu primitives.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
