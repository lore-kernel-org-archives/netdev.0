From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] act_nat: fix on the TX path
Date: Wed, 04 Aug 2010 21:54:45 -0700 (PDT)
Message-ID: <20100804.215445.212661939.davem@davemloft.net>
References: <1280893158-22103-1-git-send-email-xiaosuo@gmail.com>
	<20100804070621.GB370@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, hadi@cyberus.ca, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59442
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754423Ab0HEEy0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Aug 2010 00:54:26 -0400
In-Reply-To: <20100804070621.GB370@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 4 Aug 2010 15:06:21 +0800

> On Wed, Aug 04, 2010 at 11:39:18AM +0800, Changli Gao wrote:
>> On the TX path, skb->data points to the ethernet header, not the network
>> header. So when validating the packet length for accessing we should
>> take the ethernet header into account.
>> 
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks.
