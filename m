From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Known problems with TCP window size on 2.6.7?
Date: Thu, 28 Oct 2004 08:07:13 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041027220713.GA2468@gondor.apana.org.au>
References: <20041027110617.GA28757@vana.vc.cvut.cz> <E1CMml4-0001Cm-00@gondolin.me.apana.org.au> <20041027145356.6c22959e.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vandrove@vc.cvut.cz, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041027145356.6c22959e.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Oct 27, 2004 at 02:53:56PM -0700, David S. Miller wrote:
> 
> Actually Herbert, we did have a window 16-bit overflow problem in 2.6.7
> which I believe was first fixed in 2.6.8 or so.  It was fixed by this
> patch:

Sorry, you're right.  This is probably what's causing it then.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
