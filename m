From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: tcp: Do not apply TSO segment limit to non-TSO packets
Date: Fri, 16 Jan 2015 21:50:13 +1100
Message-ID: <20150116105012.GA10655@gondor.apana.org.au>
References: <1709726.jUgUSQI9sl@pikkukde.a.i2n>
 <20141201102522.GA16579@gondor.apana.org.au>
 <20141231133923.GA30248@gondor.apana.org.au>
 <74814478.Xs0dcijNdd@storm>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, edumazet@google.com,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>
To: Thomas Jarosch <thomas.jarosch@intra2net.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:49067 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751918AbbAPKuU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 05:50:20 -0500
Content-Disposition: inline
In-Reply-To: <74814478.Xs0dcijNdd@storm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 16, 2015 at 11:45:44AM +0100, Thomas Jarosch wrote:
> 
> For backporting to -stable: Kernel 3.14 lacks tcp_tso_autosize().
> So I've borrowed that from 3.19-rc4+ and also added the max_segs variable.
> The final and tested code looks like this:

You don't need tcp_tso_autosize.  Instead of testing max_segs just
test sk->sk_gso_max_segs.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
