From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] ep93xx_eth stopps receiving packets
Date: Tue, 4 May 2010 03:46:07 +0200
Message-ID: <20100504014606.GI4586@mail.wantstofly.org>
References: <20100419173813.7750395f4fkkmrk0@limpopo.deheime.ch> <20100502104350.GS4586@mail.wantstofly.org> <20100503134244.42345pyaszhd9f8c@limpopo.deheime.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stefan Agner <stefan@agner.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:39751 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754910Ab0EDBqM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 21:46:12 -0400
Content-Disposition: inline
In-Reply-To: <20100503134244.42345pyaszhd9f8c@limpopo.deheime.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 03, 2010 at 01:42:44PM +0200, Stefan Agner wrote:

> Receiving small packet(s) in a fast pace leads to not receiving any
> packets at all after some time.
> 
> After ethernet packet(s) arrived the receive descriptor is incremented
> by the number of frames processed. If another packet arrives while
> processing, this is processed in another call of ep93xx_rx. This
> second call leads that too many receive descriptors getting released.
> 
> This fix increments, even in these case, the right number of processed
> receive descriptors.
> 
> Signed-off-by: Stefan Agner <stefan@agner.ch>

I haven't opened my ep93xx docs for a while, but if this works for you:

Acked-by: Lennert Buytenhek <buytenh@wantstofly.org>

Thanks!
