From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] bnx2x: Remove two prefetch()
Date: Tue, 27 Apr 2010 15:19:37 -0700 (PDT)
Message-ID: <20100427.151937.62344362.davem@davemloft.net>
References: <1272018366.7895.7930.camel@edumazet-laptop>
	<20100427.150817.84390202.davem@davemloft.net>
	<1272406693.2343.26.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, hadi@cyberus.ca, therbert@google.com,
	shemminger@vyatta.com, netdev@vger.kernel.org, eilong@broadcom.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50530
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753464Ab0D0WTb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 18:19:31 -0400
In-Reply-To: <1272406693.2343.26.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 28 Apr 2010 00:18:13 +0200

> [PATCH net-next-2.6] bnx2x: Remove two prefetch()
> 
> 1) Even on 64bit arches, sizeof(struct sk_buff) < 256
> 2) No need to prefetch same pointer twice.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Eilon Greenstein <eilong@broadcom.com>

Eilon please review and ACK/NACK

Thanks.
