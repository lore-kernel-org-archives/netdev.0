From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPv4] Kill remnant of ip_nat_dumb
Date: Thu, 23 Sep 2004 18:12:55 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1CAOil-0005Ot-00@gondolin.me.apana.org.au>
References: <20040923061923.GL3236@sunbeam.de.gnumonks.org>
Cc: ak@suse.de, davem@davemloft.net, hadi@cyberus.ca,
        herbert@gondor.apana.org.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: laforge@gnumonks.org (Harald Welte)
In-Reply-To: <20040923061923.GL3236@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Harald Welte <laforge@gnumonks.org> wrote:
> 
> From a functionality point of view: yes.  
> 
> From a performance point of view, there are applications for really dumb
> static NAT where you don't want to pull all the dependencies from
> ip_conntrack over ip_tables.

Well the problem is nobody is stepping forward to fix it.  It was removed
not because it was redundant, but because it was broken.

Until someone actually fixes it, it can't go back in.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
