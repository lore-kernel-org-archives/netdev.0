From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [0/5] GSO: Generic Segmentation Offload
Date: Sat, 24 Jun 2006 15:36:25 +1000
Message-ID: <20060624053625.GA8679@gondor.apana.org.au>
References: <20060622081211.GA22505@gondor.apana.org.au> <20060622.232801.02912673.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35086 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932846AbWFXFgo
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Jun 2006 01:36:44 -0400
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20060622.232801.02912673.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 22, 2006 at 11:28:01PM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
> 
> Can you measure some with other sizes,
> e.g. 4kByte, 8kByte, 9000Byte?

GSO like TSO is less effective when the MTU is larger.  However, NICs
supporting larger MTUs also support SG.  So the figures I included for
lo should apply.  In those scenarios, GSO is basically on par with the
default segmentation.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
