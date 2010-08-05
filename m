From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix napi_gro_frags vs netpoll path
Date: Thu, 05 Aug 2010 12:01:43 -0700 (PDT)
Message-ID: <20100805.120143.91362250.davem@davemloft.net>
References: <20100805110355.GA19965@ff.dom.local>
	<20100805114059.GA15063@gondor.apana.org.au>
	<20100805114944.GA21894@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	xiaohui.xin@intel.com
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56536
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756867Ab0HETBY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Aug 2010 15:01:24 -0400
In-Reply-To: <20100805114944.GA21894@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Thu, 5 Aug 2010 11:49:44 +0000

> On Thu, Aug 05, 2010 at 07:40:59PM +0800, Herbert Xu wrote:
>> On Thu, Aug 05, 2010 at 11:03:55AM +0000, Jarek Poplawski wrote:
>> > 
>> > The netpoll_rx_on() check in dev_gro_receive() skips part of the
>> > "common" GRO_NORMAL path, especially "pull:" in dev_gro_receive(),
>> > where at least eth header should be copied for entirely paged skbs.
>> > 
>> > Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
>> 
>> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> I hope, David will use it with a nearby v2 (the changelog fixed).

I will :-)
