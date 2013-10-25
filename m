From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: crypto: skcipher - Use eseqiv even on UP machines
Date: Fri, 25 Oct 2013 08:50:49 +0200
Message-ID: <20131025065049.GB31491@secunet.com>
References: <20131024124149.GA10587@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131024124149.GA10587@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 24, 2013 at 08:41:49PM +0800, Herbert Xu wrote:
> Hi:
>     
> Previously we would use eseqiv on all async ciphers in all cases,
> and sync ciphers if we have more than one CPU.  This meant that
> chainiv is only used in the case of sync ciphers on a UP machine.
> 
> As chainiv may aid attackers by making the IV predictable, even
> though this risk itself is small, the above usage pattern causes
> it to further leak information about the host.
> 
> This patch addresses these issues by using eseqiv even if we're
> on a UP machine.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 

That's fine by me.

Acked-by: Steffen Klassert <steffen.klassert@secunet.com>
