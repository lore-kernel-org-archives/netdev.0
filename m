From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [CRYPTO] Fix stack overrun in crypt()
Date: Sat, 17 Jul 2004 19:48:29 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040717094829.GA19791@gondor.apana.org.au>
References: <20040715114840.GA1325@gondor.apana.org.au> <Pine.LNX.4.58.0407161126350.13406@devserv.devel.redhat.com> <20040717074319.GA18919@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040717074319.GA18919@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Jul 17, 2004 at 05:43:19PM +1000, herbert wrote:
> 
> Unfortunately it looks like we still have a problem. gcc 3.3.4 appears
> to be generating incorrect output on i386 with the dynamic stack
> allocation used in crypt() and the functions around it.
> 
> In particular, it can give you 8 bytes when you ask for 16 bytes.
> See my report at http://bugs.debian.org/259887 for details.

I got it wrong.  gcc is simply allocating some (12 bytes) of the
space unconditionally.

Sorry for the noise.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
