From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/2] ipv6: Store ndisc_nodeid in IP6CB().
Date: Thu, 20 May 2010 13:35:29 +1000
Message-ID: <20100520033529.GB6434@gondor.apana.org.au>
References: <20100519.195536.32704411.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bmb@athenacr.com, tgraf@redhat.com, nhorman@tuxdriver.com,
	nhorman@redhat.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:52300 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753410Ab0ETDfl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 May 2010 23:35:41 -0400
Content-Disposition: inline
In-Reply-To: <20100519.195536.32704411.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 19, 2010 at 07:55:36PM -0700, David Miller wrote:
> 
> There is no reason we need to use up space in the generic
> SKB area for this.  All packet input paths in ipv6 explicitly
> clear out the IP6CB() area and therefore the default value
> for ndisc_nodeid will be correct.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>

Looks good to me.  Thanks!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
