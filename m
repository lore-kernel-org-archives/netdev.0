From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add __rcu annotations to protocol
Date: Wed, 27 Oct 2010 11:22:39 -0700 (PDT)
Message-ID: <20101027.112239.70184062.davem@davemloft.net>
References: <1288076548.3296.89.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35697
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754527Ab0J0SWQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 14:22:16 -0400
In-Reply-To: <1288076548.3296.89.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 26 Oct 2010 09:02:28 +0200

> Add __rcu annotations to :
>         struct net_protocol *inet_protos
>         struct net_protocol *inet6_protos
> 
> And use appropriate casts to reduce sparse warnings if
> CONFIG_SPARSE_RCU_POINTER=y
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
