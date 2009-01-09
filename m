From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Make possible speeds known to ethtool
Date: Fri, 9 Jan 2009 15:19:53 +1100
Message-ID: <20090109041952.GA12087@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bhutchings@solarflare.com, rick.jones2@hp.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:48195 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752244AbZAIEUG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 23:20:06 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik <jgarzik@pobox.com> wrote:
>
> For generic net stack flags outside the driver's control, that can 
> easily be added to ethtool_{get,set}_flags() overriding or ignoring 
> whatever the driver may have done.

To use the flags interface as is, you'd have to go through every
single driver to get them to call ethtool_op_set_flags.  I'm sorry
but I'm sticking with the current interface.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
