From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 7/7] mac80211: Switch to new AEAD interface
Date: Thu, 21 May 2015 19:50:14 +0800
Message-ID: <20150521115013.GA23833@gondor.apana.org.au>
References: <20150521103938.GA23035@gondor.apana.org.au>
 <E1YvNxS-00063i-AZ@gondolin.me.apana.org.au>
 <1432207249.2343.9.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1432207249.2343.9.camel@sipsolutions.net>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 21, 2015 at 01:20:49PM +0200, Johannes Berg wrote:
> On Thu, 2015-05-21 at 18:44 +0800, Herbert Xu wrote:
> > This patch makes use of the new AEAD interface which uses a single
> > SG list instead of separate lists for the AD and plain text.
> 
> Looks fine - want me to run any tests on it?

That would be great!

However, they depend on a series which has not been merged into
cryptodev yet so you'll need to apply the following pathces first:

https://www.mail-archive.com/linux-crypto@vger.kernel.org/msg14270.html

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
