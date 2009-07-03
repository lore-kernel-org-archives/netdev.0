From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/2] xfrm4: fix the ports decode of sctp protocol
Date: Fri, 3 Jul 2009 11:48:49 +0800
Message-ID: <20090703034849.GA23183@gondor.apana.org.au>
References: <4A4D7393.1060303@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:36585 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751475AbZGCDsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 23:48:55 -0400
Content-Disposition: inline
In-Reply-To: <4A4D7393.1060303@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 03, 2009 at 10:57:23AM +0800, Wei Yongjun wrote:
> The SCTP pushed the skb data above the sctp chunk header, so the check
> of pskb_may_pull(skb, xprth + 4 - skb->data) in _decode_session4() will
> never return 0 because xprth + 4 - skb->data < 0, the ports decode of
> sctp will always fail.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Longer term I wonder if we can move this stuff into the protocol
code, i.e., before they call xfrm_policy_check.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
