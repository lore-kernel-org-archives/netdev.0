From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [17/*] [NET] Replace dst_pmtu with dst_mtu
Date: Wed, 16 Mar 2005 07:31:52 +1100
Message-ID: <20050315203152.GA22349@gondor.apana.org.au>
References: <20050306213214.7d8a143d.davem@davemloft.net> <20050307103536.GB7137@gondor.apana.org.au> <20050308102741.GA23468@gondor.apana.org.au> <20050314102614.GA9610@gondor.apana.org.au> <20050314105313.GA21001@gondor.apana.org.au> <20050314111002.GA29156@gondor.apana.org.au> <20050315091904.GA6256@gondor.apana.org.au> <20050315095837.GA7130@gondor.apana.org.au> <20050315100522.GA7275@gondor.apana.org.au> <20050315102450.0f3f1618.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, kaber@trash.net,
        netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050315102450.0f3f1618.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Mar 15, 2005 at 10:24:50AM -0800, David S. Miller wrote:
> 
> So, at that point, I guess the next task is to handle PMTU events of already
> encrypted packets properly?  We still have that problem right?  When the
> ICMP payload is encrypted we have to cache some information on IPSEC output
> so that a proto+SPI key can find us the encrypted inner IP header info, which
> we'll need in order to process (and/or forward) the ICMP PMTU information
> correctly.

Yes, that's going to be the second part of the MTU work.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
