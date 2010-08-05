From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] Fix napi_gro_frags vs netpoll path
Date: Thu, 5 Aug 2010 11:49:44 +0000
Message-ID: <20100805114944.GA21894@ff.dom.local>
References: <20100805110355.GA19965@ff.dom.local> <20100805114059.GA15063@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Xin, Xiaohui" <xiaohui.xin@intel.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:55126 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755733Ab0HELtv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Aug 2010 07:49:51 -0400
Received: by fxm14 with SMTP id 14so2781324fxm.19
        for <netdev@vger.kernel.org>; Thu, 05 Aug 2010 04:49:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20100805114059.GA15063@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 05, 2010 at 07:40:59PM +0800, Herbert Xu wrote:
> On Thu, Aug 05, 2010 at 11:03:55AM +0000, Jarek Poplawski wrote:
> > 
> > The netpoll_rx_on() check in dev_gro_receive() skips part of the
> > "common" GRO_NORMAL path, especially "pull:" in dev_gro_receive(),
> > where at least eth header should be copied for entirely paged skbs.
> > 
> > Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

I hope, David will use it with a nearby v2 (the changelog fixed).

Thanks,
Jarek P.
