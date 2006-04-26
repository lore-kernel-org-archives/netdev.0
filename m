From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: ipsec tunnel asymmetrical mtu
Date: Wed, 26 Apr 2006 20:55:46 +1000
Message-ID: <20060426105546.GA11726@gondor.apana.org.au>
References: <E1FXVdb-0003Tt-00@gondolin.me.apana.org.au> <BAY103-F290B963EE35123CC2E6DB8B2BE0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:21261 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932385AbWDZKzs
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Apr 2006 06:55:48 -0400
To: Marco Berizzi <pupilla@hotmail.com>
Content-Disposition: inline
In-Reply-To: <BAY103-F290B963EE35123CC2E6DB8B2BE0@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 24, 2006 at 09:23:00AM +0000, Marco Berizzi wrote:
> 
> What should I do? Mangling MSS with iptables  --set-mss ?
> Altering MSS to 1440 did the trick. See:
> http://marc.theaimsgroup.com/?l=linux-netdev&m=114373067423528&w=2

--clamp-mss-to-pmtu should be the best option.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
