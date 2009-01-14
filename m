From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH]IPv6:remove duplicate check of optlen when setsockopt
	with IPV6_PKTINFO option
Date: Wed, 14 Jan 2009 15:48:56 +1100
Message-ID: <20090114044856.GA14726@gondor.apana.org.au>
References: <496D61FE.7080500@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Yang Hongyang <yanghy@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47506 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752919AbZANEtA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 23:49:00 -0500
Content-Disposition: inline
In-Reply-To: <496D61FE.7080500@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yang Hongyang <yanghy@cn.fujitsu.com> wrote:
>
> If optval==NULL, what we should return?EINVAL or EFAULT?
> If it is EINVAL,then we should check it .otherwise it's the job of 
> copy_from_user

I think EFAULT is fine.  We return that elsewhere as well.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
