From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH BUG-FIX] ipv6: udp: fix the wrong headroom check
Date: Thu, 21 Apr 2011 10:39:37 -0700 (PDT)
Message-ID: <20110421.103937.241933113.davem@davemloft.net>
References: <4DAE9EE1.1050405@cn.fujitsu.com>
	<20110420105007.GA16248@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shanwei@cn.fujitsu.com, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49496
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751778Ab1DURkL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2011 13:40:11 -0400
In-Reply-To: <20110420105007.GA16248@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 20 Apr 2011 18:50:07 +0800

> On Wed, Apr 20, 2011 at 04:52:49PM +0800, Shan Wei wrote:
>> At this point, skb->data points to skb_transport_header.
>> So, headroom check is wrong. 
>> 
>> For some case:bridge(UFO is on) + eth device(UFO is off),
>> there is no enough headroom for IPv6 frag head.
>> But headroom check is always false.
>> 
>> This will bring about data be moved to there prior to skb->head,
>> when adding IPv6 frag header to skb.
>> 
>> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
> 
> Ouch.
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks.
