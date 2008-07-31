From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] ipv6: Fix ip6_xmit to send fragments if ipfragok is true
Date: Thu, 31 Jul 2008 17:23:21 +0800
Message-ID: <20080731092321.GA6907@gondor.apana.org.au>
References: <489153ED.9030701@cn.fujitsu.com> <20080731082053.GA6463@gondor.apana.org.au> <489181DC.40507@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:54040 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752655AbYGaJXj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 05:23:39 -0400
Content-Disposition: inline
In-Reply-To: <489181DC.40507@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 31, 2008 at 05:11:56PM +0800, Wei Yongjun wrote:
>
> So what does the ipfragok paramater means?
> TCP used  ip6_xmit always set ipfragok = 0. But if ipfragok=1, what will 
> happend?

OK it's already been butchered for SCTP :)

In that case you should set local_df iff ipfragok is true.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
