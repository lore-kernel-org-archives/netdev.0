From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fw: [BUGS] [CHECKER] 99 synchronization bugs and a lock summary database
Date: Fri, 02 Jul 2004 21:04:59 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1BgLql-00055X-00@gondolin.me.apana.org.au>
References: <20040702004956.448c95d9.akpm@osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org (Andrew Morton)
In-Reply-To: <20040702004956.448c95d9.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@osdl.org> wrote:
> 
> Could someone please take a look at the locking in
> net/ipv4/ipmr.c:ipmr_mfc_seq_next?  It seems rather broken.

Obfuscated yes, broken no.  Unfortunately the seq interface tends to
produce code like this.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
