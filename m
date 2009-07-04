From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] xfrm4: fix the ports decode of sctp protocol
Date: Fri, 03 Jul 2009 19:10:59 -0700 (PDT)
Message-ID: <20090703.191059.106410069.davem@davemloft.net>
References: <4A4D7393.1060303@cn.fujitsu.com>
	<20090703034849.GA23183@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yjwei@cn.fujitsu.com, netdev@vger.kernel.org,
	vladislav.yasevich@hp.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36273
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754910AbZGDCKw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2009 22:10:52 -0400
In-Reply-To: <20090703034849.GA23183@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 3 Jul 2009 11:48:49 +0800

> On Fri, Jul 03, 2009 at 10:57:23AM +0800, Wei Yongjun wrote:
>> The SCTP pushed the skb data above the sctp chunk header, so the check
>> of pskb_may_pull(skb, xprth + 4 - skb->data) in _decode_session4() will
>> never return 0 because xprth + 4 - skb->data < 0, the ports decode of
>> sctp will always fail.
>> 
>> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.

> Longer term I wonder if we can move this stuff into the protocol
> code, i.e., before they call xfrm_policy_check.

That ought to work.
