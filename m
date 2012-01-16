From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net 1/2] net: Use device model to get driver name in
	skb_gso_segment()
Date: Tue, 17 Jan 2012 09:41:38 +1100
Message-ID: <20120116224138.GA12523@gondor.apana.org.au>
References: <1326753539.3065.31.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:47058 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751239Ab2APWlo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2012 17:41:44 -0500
Content-Disposition: inline
In-Reply-To: <1326753539.3065.31.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 16, 2012 at 10:38:59PM +0000, Ben Hutchings wrote:
> ethtool operations generally require the caller to hold RTNL and are
> not safe to call in atomic context.  The device model provides this
> information for most devices; we'll only lose it for some old ISA
> drivers.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
