From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [DEBUG]: sk_forward_alloc assertion failures
Date: Mon, 17 Jan 2005 12:37:29 -0800
Message-ID: <20050117123729.526ccdc7.davem@davemloft.net>
References: <20050114120322.GA28449@gondor.apana.org.au>
	<20050114110352.23c94ab9.davem@davemloft.net>
	<20050114203452.GA1277@gondor.apana.org.au>
	<20050114132757.4ca3153a.davem@davemloft.net>
	<20050114213829.GA12454@gondor.apana.org.au>
	<20050114133611.69ff0bb2.davem@davemloft.net>
	<20050114215504.GA12569@gondor.apana.org.au>
	<20050114140426.5cf06f0c.davem@davemloft.net>
	<20050114224745.GA13180@gondor.apana.org.au>
	<20050114205543.5acb0d68.davem@davemloft.net>
	<20050115054547.GA15860@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050115054547.GA15860@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 15 Jan 2005 16:45:47 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> > +		if (sk->sk_forward_alloc < copy &&
> > +		    !sk_stream_mem_schedule(sk, copy, 0))
> 
> You want to have sk->sk_allocation here instead of 0.

The third argument to sk_stream_mem_schedule() is "int kind"
which is to be set to 1 for receive packet allocations and 0
for send packet allocations.

Why would I want to use a sk_allocation gfp mask here? :-)
