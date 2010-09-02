From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: don't do GRO on second port
Date: Thu, 02 Sep 2010 10:08:12 -0700 (PDT)
Message-ID: <20100902.100812.48509810.davem@davemloft.net>
References: <1283419909.2454.137.camel@edumazet-laptop>
	<20100902095502.GA8775@ff.dom.local>
	<1283424105.2454.311.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, shemminger@vyatta.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34192
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752921Ab0IBRH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 13:07:56 -0400
In-Reply-To: <1283424105.2454.311.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 02 Sep 2010 12:41:45 +0200

> [PATCH net-next-2.6] gro: remove use of napi->dev
> 
> Only use of napi->dev in GRO stack is the one found in napi_get_frags()
> 
> We can remove it and use a plain dev_alloc_skb() call.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

If you change this to use skb->dev I can apply this.

Thanks.
