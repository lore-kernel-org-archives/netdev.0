From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: ipsec tunnel asymmetrical mtu
Date: Tue, 11 Jul 2006 20:42:38 +1000
Message-ID: <20060711104238.GA10976@gondor.apana.org.au>
References: <20060711064232.GA1490@gondor.apana.org.au> <BAY103-F203CAD498C086FD90B8381B2680@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:17937 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750992AbWGKKmk
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 06:42:40 -0400
To: Marco Berizzi <pupilla@hotmail.com>
Content-Disposition: inline
In-Reply-To: <BAY103-F203CAD498C086FD90B8381B2680@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 11, 2006 at 11:22:18AM +0200, Marco Berizzi wrote:
>
> I'm able to connect to a sap server connected to the milano network
> from a sapgui client connected to the venezia network. No problem.
> If packet loss is a problem it should be also a problem with this tunnel.
> Am I wrong?

It depends.  A mild packet loss problem can become a big one when it
is exacerbated by fragmentation, e.g., a 20% rate can become 40%.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
