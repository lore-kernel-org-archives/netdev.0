From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [XFRM] Call dst_check() with appropriate cookie
Date: Tue, 24 May 2005 22:50:28 +1000
Message-ID: <20050524125028.GA27278@gondor.apana.org.au>
References: <E1DaTeW-00085B-00@gondolin.me.apana.org.au> <4292E53D.7030805@miyazawa.org> <20050524083419.GA31586@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: YOSHIFUJI Hideaki / ???? <yoshfuji@linux-ipv6.org>, davem@davemloft.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Kazunori Miyazawa <kazunori@miyazawa.org>
Content-Disposition: inline
In-Reply-To: <20050524083419.GA31586@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, May 24, 2005 at 06:34:19PM +1000, herbert wrote:
> 
> Yes this makes perfect sense.  However, I'd still like to know why I
> have never seen it myself.  Let me double-check my test setup.

Aha, not all IPv6 dst entries have obsolete set to -1.  Obviously
your ones were and mine weren't :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
