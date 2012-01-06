From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: HMAC and stuff
Date: Fri, 6 Jan 2012 12:34:29 +1100
Message-ID: <20120106013429.GA6401@gondor.apana.org.au>
References: <20111229173101.GA3706@p183.telecom.by>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20111229173101.GA3706@p183.telecom.by>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan <adobriyan@gmail.com> wrote:
> aalg_list array contains list of "approved" HMAC algorightms.
> Do I understand correctly that to update this list some sort of
> official document like RFC has to be present?

The table is mainly there for the benefit of af_key.  It should
be relatively easy to make xfrm_user look up any algorithm by
name only.

However, we'll need to do something about representing those
algorithms through the af_key interface since that one uses
numeric IDs only.  The easiest is to pick an ID that we then
forbid when used to create new SAs.

Ccing netdev since this is really an IPsec issue, not crypto.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
