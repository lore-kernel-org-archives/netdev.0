From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [DEBUG]: sk_forward_alloc assertion failures
Date: Tue, 18 Jan 2005 07:40:38 +1100
Message-ID: <20050117204038.GB9605@gondor.apana.org.au>
References: <20050114203452.GA1277@gondor.apana.org.au> <20050114132757.4ca3153a.davem@davemloft.net> <20050114213829.GA12454@gondor.apana.org.au> <20050114133611.69ff0bb2.davem@davemloft.net> <20050114215504.GA12569@gondor.apana.org.au> <20050114140426.5cf06f0c.davem@davemloft.net> <20050114224745.GA13180@gondor.apana.org.au> <20050114205543.5acb0d68.davem@davemloft.net> <20050115054547.GA15860@gondor.apana.org.au> <20050117123729.526ccdc7.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050117123729.526ccdc7.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Jan 17, 2005 at 12:37:29PM -0800, David S. Miller wrote:
> On Sat, 15 Jan 2005 16:45:47 +1100
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > > +		if (sk->sk_forward_alloc < copy &&
> > > +		    !sk_stream_mem_schedule(sk, copy, 0))
> > 
> > You want to have sk->sk_allocation here instead of 0.
> 
> The third argument to sk_stream_mem_schedule() is "int kind"
> which is to be set to 1 for receive packet allocations and 0
> for send packet allocations.
> 
> Why would I want to use a sk_allocation gfp mask here? :-)

You're right.  I got carried away there :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
