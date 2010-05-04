From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ep93xx_eth stopps receiving packets
Date: Mon, 03 May 2010 23:23:29 -0700 (PDT)
Message-ID: <20100503.232329.247148256.davem@davemloft.net>
References: <20100502104350.GS4586@mail.wantstofly.org>
	<20100503134244.42345pyaszhd9f8c@limpopo.deheime.ch>
	<20100504014606.GI4586@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stefan@agner.ch, netdev@vger.kernel.org
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46281
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755971Ab0EDGXW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 02:23:22 -0400
In-Reply-To: <20100504014606.GI4586@mail.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Tue, 4 May 2010 03:46:07 +0200

> On Mon, May 03, 2010 at 01:42:44PM +0200, Stefan Agner wrote:
> 
>> Receiving small packet(s) in a fast pace leads to not receiving any
>> packets at all after some time.
>> 
>> After ethernet packet(s) arrived the receive descriptor is incremented
>> by the number of frames processed. If another packet arrives while
>> processing, this is processed in another call of ep93xx_rx. This
>> second call leads that too many receive descriptors getting released.
>> 
>> This fix increments, even in these case, the right number of processed
>> receive descriptors.
>> 
>> Signed-off-by: Stefan Agner <stefan@agner.ch>
> 
> I haven't opened my ep93xx docs for a while, but if this works for you:
> 
> Acked-by: Lennert Buytenhek <buytenh@wantstofly.org>

I had to apply this by hand because Stefan's email client corrupted the
spacing et al. in the patch.  Stefan please post a usable patch next
time.
