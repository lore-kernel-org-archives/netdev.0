From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [patch 1/3] fix buggy IEEE80211_CRYPT_* selects
Date: Sun, 6 Mar 2005 20:09:36 +1100
Message-ID: <20050306090936.GA31890@gondor.apana.org.au>
References: <200503041237.j24Cbb69026470@shell0.pdx.osdl.net> <42289BDF.1080409@pobox.com> <20050304221014.GJ3327@stusta.de> <4228DF62.4000205@pobox.com> <20050304230718.GL3327@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, akpm@osdl.org, davem@davemloft.net,
        netdev@oss.sgi.com
To: Adrian Bunk <bunk@stusta.de>
Content-Disposition: inline
In-Reply-To: <20050304230718.GL3327@stusta.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Mar 05, 2005 at 12:07:18AM +0100, Adrian Bunk wrote:
> 
> The way kconfig currently works, you have to ensure that the 
> dependencies of what you select are fulfilled.

Yes Adrian's right.  In the other places where we select CRYPTO
symbols, we always make sure that CRYPTO itself is selected.  See
net/ipv4/Kconfig for example.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
