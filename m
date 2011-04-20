From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH BUG-FIX] ipv6: udp: fix the wrong headroom check
Date: Wed, 20 Apr 2011 18:50:07 +0800
Message-ID: <20110420105007.GA16248@gondor.apana.org.au>
References: <4DAE9EE1.1050405@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, David Miller <davem@davemloft.net>,
	pekkas@netcore.fi, jmorris@namei.org,
	"yoshfuji@linux-ipv6.org >> YOSHIFUJI Hideaki"
	<yoshfuji@linux-ipv6.org>, Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:53394 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753944Ab1DTKuu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 06:50:50 -0400
Content-Disposition: inline
In-Reply-To: <4DAE9EE1.1050405@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 20, 2011 at 04:52:49PM +0800, Shan Wei wrote:
> At this point, skb->data points to skb_transport_header.
> So, headroom check is wrong. 
> 
> For some case:bridge(UFO is on) + eth device(UFO is off),
> there is no enough headroom for IPv6 frag head.
> But headroom check is always false.
> 
> This will bring about data be moved to there prior to skb->head,
> when adding IPv6 frag header to skb.
> 
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>

Ouch.

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
