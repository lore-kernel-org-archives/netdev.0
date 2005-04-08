From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fw: Re: 2.6.12-rc2-mm2
Date: Sat, 09 Apr 2005 08:36:29 +1000
Message-ID: <E1DK25V-0005Ye-00@gondolin.me.apana.org.au>
References: <20050408093630.0ff78c67.akpm@osdl.org>
Cc: netdev@oss.sgi.com, indrek.kruusa@tuleriit.ee
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org (Andrew Morton)
In-Reply-To: <20050408093630.0ff78c67.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@osdl.org> wrote:
> 
> dmesg is not clean though:
> 
> TCP: time wait bucket table overflow
> TCP: time wait bucket table overflow
> TCP: time wait bucket table overflow
> printk: 392 messages suppressed.
> 
> What I did:
> - "bombing" httpd with JMeter (from another computer)

This is normal.  The number of TCP connections held by
your server in the TIME_WAIT state is exceeding
tcp_max_tw_buckets.

Check out tcp(7) on what this means and how it may or
may not be a problem for you.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
