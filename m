From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [XFRM] Convert XFRM_MSG_* macros to an enum
Date: Sat, 3 Jul 2004 20:02:08 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040703100208.GA16339@gondor.apana.org.au>
References: <20040703095215.GA16195@gondor.apana.org.au> <20040703.190042.70899669.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20040703.190042.70899669.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Jul 03, 2004 at 07:00:42PM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
> 
> Well, I think we'd better to do
> 
>  #define XFRM_MSG_GETSA XFRM_MSG_GETSA
> 
> etc. because this would break (future) applications which do
> #ifdef.

I think such applications are broken.

They should compile with headers that define these symbols and
test for their support at run-time.

Applications should not detect kernel features at compile-time.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
