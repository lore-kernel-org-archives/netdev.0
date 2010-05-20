From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/2] net: Add classid to sk_buff.
Date: Thu, 20 May 2010 13:36:43 +1000
Message-ID: <20100520033643.GA6630@gondor.apana.org.au>
References: <20100519.195538.139536660.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bmb@athenacr.com, tgraf@redhat.com, nhorman@tuxdriver.com,
	nhorman@redhat.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:56671 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753258Ab0ETDgy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 May 2010 23:36:54 -0400
Content-Disposition: inline
In-Reply-To: <20100519.195538.139536660.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 19, 2010 at 07:55:38PM -0700, David Miller wrote:
> 
> We make this zero cost by moving queue_mapping into an existing
> empty __u16 slot.  Thus making a __u32 available, which we use
> for the 'classid'.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>

You better hide this space before someone steals it :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
