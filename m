From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Move inetdev/ifa over to RCU
Date: Mon, 16 Aug 2004 12:43:30 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040816024329.GA8127@gondor.apana.org.au>
References: <20040813093838.6961c0d4.davem@redhat.com> <20040813215602.GA15870@gondor.apana.org.au> <20040813151923.3311b4f0.davem@redhat.com> <20040814003428.GA17760@gondor.apana.org.au> <20040813173924.6d05be15.davem@redhat.com> <20040814005411.GA18350@gondor.apana.org.au> <20040814012513.GA721@gondor.apana.org.au> <20040814013030.GA2042@gondor.apana.org.au> <20040814050848.GA11874@gondor.apana.org.au> <20040815190823.654bf2d5.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040815190823.654bf2d5.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Aug 15, 2004 at 07:08:23PM -0700, David S. Miller wrote:
>
> > Do we really care about the zero return value of inet_select_addr()
> > here? What about the other calls to inet_select_addr()?
> 
> It won't return zero, typically it will return loopback's IP
> (with preference to any non-loopback addresses assigned to
>  the loopback device).  This is being used for source address
> selection.

It will return zero if there is no in_dev at all.  Perhaps what
we should do is get inet_select_addr() to get the address from
other devices in that case as well?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
