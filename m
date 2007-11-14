From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/2] [IPSEC]: Add async resume support on input
Date: Wed, 14 Nov 2007 14:36:58 +0800
Message-ID: <20071114063657.GA11293@gondor.apana.org.au>
References: <20071113.214609.04000914.davem@davemloft.net> <20071114062758.GA11173@gondor.apana.org.au> <20071114062834.GB11173@gondor.apana.org.au> <20071113.223356.216207937.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2860 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756845AbXKNGhA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 01:37:00 -0500
Content-Disposition: inline
In-Reply-To: <20071113.223356.216207937.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 13, 2007 at 10:33:56PM -0800, David Miller wrote:
>
> Also applied to net-2.6.25, thanks.
> 
> I'll work on integrating Patrick's NF_INET_* patch next.

Thanks! With that you would be able to remove the nf_post_routing
field from xfrm_state_afinfo.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
