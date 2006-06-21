From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: + myri10ge-build-fix.patch added to -mm tree
Date: Wed, 21 Jun 2006 22:28:28 +1000
Message-ID: <20060621122828.GA16176@gondor.apana.org.au>
References: <200606210433.k5L4XgmP008626@shell0.pdx.osdl.net> <20060621044107.GB899@gondor.apana.org.au> <4499370F.2020101@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, mm-commits@vger.kernel.org, davem@davemloft.net,
	jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:49931 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751411AbWFUM25
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jun 2006 08:28:57 -0400
To: Brice Goglin <brice@myri.com>
Content-Disposition: inline
In-Reply-To: <4499370F.2020101@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 21, 2006 at 12:09:51PM +0000, Brice Goglin wrote:
> 
> Actually, we use 64 segments when TSO in enabled
> (MYRI10GE_MAX_SEND_DESC_TSO):
> 
> #define MYRI10GE_MAX_SEND_DESC_TSO ((65536 / 2048) * 2)

You're right, I missed that bit.  Sorry about the noise.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
