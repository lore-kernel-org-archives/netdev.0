From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [TCP] Show all SYN_RECV sockets in /proc/net/tcp
Date: Wed, 06 Oct 2004 12:35:58 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1CF1eo-0003qW-00@gondolin.me.apana.org.au>
References: <416355BD.50402@conectiva.com.br>
Cc: herbert@gondor.apana.org.au, davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: acme@conectiva.com.br (Arnaldo Carvalho de Melo)
In-Reply-To: <416355BD.50402@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Arnaldo Carvalho de Melo <acme@conectiva.com.br> wrote:
> 
> Go ahead and do it with the current seq_file infrastructure 8) Standard

Does the current seq_file infrastructure offer anything new compared
to what's in the existing /proc/net/tcp code?

> answer for these cases is remove /proc/net/tcp altogether and convert
> the userland tools to use netlink instead.

Completely agreed.  As I said I only started looking at this because
I was trying to fix tcp_diag.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
