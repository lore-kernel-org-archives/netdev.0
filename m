From: "David S. Miller" <davem@redhat.com>
Subject: Re: IPsec and Path MTU
Date: Thu, 17 Jun 2004 16:14:03 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040617161403.2d0ee598.davem@redhat.com>
References: <20040615124334.GA25164@gondor.apana.org.au>
	<20040616195653.GC29781@ms2.inr.ac.ru>
	<20040616231317.GA5742@gondor.apana.org.au>
	<20040617190158.GA10925@ms2.inr.ac.ru>
	<20040617213832.GC14089@gondor.apana.org.au>
	<20040617152921.730892c7.davem@redhat.com>
	<20040617231241.GB14739@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040617231241.GB14739@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 18 Jun 2004 09:12:41 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> In my case, the ICMP message is not coming from the remote IPsec gateway
> or a router in front of it.  It's coming from a host behind it.  So
> the original IP header is in the ICMP message, in the clear.

Remote gateway is supposed to encapsulate the ICMP message and send it
back to the other gateway isn't it?
