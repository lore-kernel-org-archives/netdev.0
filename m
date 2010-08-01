From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] act_nat: fix wild pointer
Date: Sat, 31 Jul 2010 22:05:08 -0700 (PDT)
Message-ID: <20100731.220508.200363956.davem@davemloft.net>
References: <1280446906-29032-1-git-send-email-xiaosuo@gmail.com>
	<20100730071838.GA7256@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, hadi@cyberus.ca, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54537
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750918Ab0HAFEu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Aug 2010 01:04:50 -0400
In-Reply-To: <20100730071838.GA7256@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 30 Jul 2010 15:18:38 +0800

> On Fri, Jul 30, 2010 at 07:41:46AM +0800, Changli Gao wrote:
>> pskb_may_pull() may change skb pointers, so adjust icmph after pskb_may_pull().
>> 
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
