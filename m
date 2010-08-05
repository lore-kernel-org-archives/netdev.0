From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Fix napi_gro_frags vs netpoll path
Date: Thu, 5 Aug 2010 19:40:59 +0800
Message-ID: <20100805114059.GA15063@gondor.apana.org.au>
References: <20100805110355.GA19965@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Xin, Xiaohui" <xiaohui.xin@intel.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:42536 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756651Ab0HELlH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Aug 2010 07:41:07 -0400
Content-Disposition: inline
In-Reply-To: <20100805110355.GA19965@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 05, 2010 at 11:03:55AM +0000, Jarek Poplawski wrote:
> 
> The netpoll_rx_on() check in dev_gro_receive() skips part of the
> "common" GRO_NORMAL path, especially "pull:" in dev_gro_receive(),
> where at least eth header should be copied for entirely paged skbs.
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
