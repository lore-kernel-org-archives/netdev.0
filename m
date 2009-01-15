From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH]IPv6:remove duplicate check of optlen when setsockopt
	with IPV6_PKTINFO option
Date: Thu, 15 Jan 2009 16:06:38 +1100
Message-ID: <20090115050638.GA30224@gondor.apana.org.au>
References: <496D61FE.7080500@cn.fujitsu.com> <20090114044856.GA14726@gondor.apana.org.au> <20090114.210242.163189105.davem@davemloft.net> <20090115050449.GA30174@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yanghy@cn.fujitsu.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:57496 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753362AbZAOFGo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 00:06:44 -0500
Content-Disposition: inline
In-Reply-To: <20090115050449.GA30174@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 15, 2009 at 04:04:49PM +1100, Herbert Xu wrote:
> On Wed, Jan 14, 2009 at 09:02:42PM -0800, David Miller wrote:
> >
> > Actually, we return EINVAL just a few lines above this code
> > block for some other socket option cases when optval==NULL.
> 
> Well the very next option IPV6_2292PKTOPTIONS returns EFAULT
> by virtue of not explicitly checking optval == NULL :)

In fact checking for a NULL pointer is strictly speaking wrong
since NULL may actually have been mapped in user-space :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
