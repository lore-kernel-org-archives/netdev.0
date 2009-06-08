From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next 2/4] udp: Handle large UFO packets from
	untrusted sources
Date: Mon, 8 Jun 2009 15:16:08 +1000
Message-ID: <20090608051608.GA19748@gondor.apana.org.au>
References: <1244247391.1526.171.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, kvm@vger.kernel.org,
	rusty@rustcorp.com.au
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1244247391.1526.171.camel@w-sridhar.beaverton.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 05, 2009 at 05:16:31PM -0700, Sridhar Samudrala wrote:
>
> +	/* Software UFO is not yet supported */
> +	segs = ERR_PTR(-EPROTONOSUPPORT);

Hmm, we need to fill this in before you start using it for virt.
After all, it's very difficult for the guest to know whether the
output device on the host is going to be able to do UFO or not.

The whole reason I did GSO in the first place is to allow the guest
not to worry about whether the host supported TSO in hardware.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
