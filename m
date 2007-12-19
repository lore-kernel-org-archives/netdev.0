From: David Miller <davem@davemloft.net>
Subject: Re: [IPSEC]: Do xfrm_state_check_space before encapsulation
Date: Tue, 18 Dec 2007 22:14:56 -0800 (PST)
Message-ID: <20071218.221456.49781139.davem@davemloft.net>
References: <4768A7CA.4090503@taca.jp>
	<20071219061210.GA6731@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: miyazawa@taca.jp, usagi-core@linux-ipv6.org, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59922
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750802AbXLSGO5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2007 01:14:57 -0500
In-Reply-To: <20071219061210.GA6731@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 19 Dec 2007 14:12:10 +0800

> [IPSEC]: Do xfrm_state_check_space before encapsulation
> 
> While merging the IPsec output path I moved the encapsulation output
> operation to the top of the loop so that it sits outside of the locked
> section.  Unfortunately in doing so it now sits in front of the space
> check as well which could be a fatal error.
> 
> This patch rearranges the calls so that the space check happens as
> the thing on the output path.
> 
> This patch also fixes an incorrect goto should the encapsulation output
> fail.
> 
> Thanks to Kazunori MIYAZAWA for finding this bug.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
