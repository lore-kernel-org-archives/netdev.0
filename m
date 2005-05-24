From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [XFRM] Call dst_check() with appropriate cookie
Date: Tue, 24 May 2005 18:34:19 +1000
Message-ID: <20050524083419.GA31586@gondor.apana.org.au>
References: <E1DaTeW-00085B-00@gondolin.me.apana.org.au> <4292E53D.7030805@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: YOSHIFUJI Hideaki / ???? <yoshfuji@linux-ipv6.org>, davem@davemloft.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Kazunori Miyazawa <kazunori@miyazawa.org>
Content-Disposition: inline
In-Reply-To: <4292E53D.7030805@miyazawa.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, May 24, 2005 at 05:26:37PM +0900, Kazunori Miyazawa wrote:
> 
> Without our patch, the dst_check in xfrm_bundle_ok returns NULL
> when it is IPv6 route, then xfrm_bundle_ok always fails.
> xfrm_lookup calls xfrm_bundle_ok via stalbe_bundle so that
> it goes to restart and recreate bundles.
> But stale_bundle always fails. It results the infinite loop accordingly.

Yes this makes perfect sense.  However, I'd still like to know why I
have never seen it myself.  Let me double-check my test setup.

Anyway, I'm happy with the patch apart from the comments I gave elsewhere
in this thread.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
