From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] xfrm6: fix the proto and ports decode of sctp
 protocol
Date: Fri, 03 Jul 2009 19:11:06 -0700 (PDT)
Message-ID: <20090703.191106.222283756.davem@davemloft.net>
References: <4A4D7393.1060303@cn.fujitsu.com>
	<4A4D7425.7080005@cn.fujitsu.com>
	<20090703034917.GB23183@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yjwei@cn.fujitsu.com, netdev@vger.kernel.org,
	vladislav.yasevich@hp.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36278
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755087AbZGDCLA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2009 22:11:00 -0400
In-Reply-To: <20090703034917.GB23183@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 3 Jul 2009 11:49:17 +0800

> On Fri, Jul 03, 2009 at 10:59:49AM +0800, Wei Yongjun wrote:
>> The SCTP pushed the skb above the sctp chunk header, so the
>> check of pskb_may_pull(skb, nh + offset + 1 - skb->data) in
>> _decode_session6() will never return 0 and the ports decode
>> of sctp will always fail. (nh + offset + 1 - skb->data < 0)
>> 
>> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
