From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [patch] do not readlock all buckets in /proc/net/tcp
Date: Mon, 5 Jul 2004 22:06:10 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040705120610.GA5728@gondor.apana.org.au>
References: <20040705110949.GA1092@suse.de> <E1BhRda-0001Rs-00@gondolin.me.apana.org.au> <20040705113555.GA28665@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Marcus Meissner <meissner@suse.de>
Content-Disposition: inline
In-Reply-To: <20040705113555.GA28665@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Jul 05, 2004 at 01:35:55PM +0200, Marcus Meissner wrote:
> 
> Oh, and NETLINK+TCP_DIAG seems to have the same readlock contention problem,
> see tcpdiag_dump().

Then you wouldn't mind adding this optimisation for tcp_diag as well,
right? :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
