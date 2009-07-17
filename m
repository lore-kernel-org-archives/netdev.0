From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [RFC] [PATCH 0/7] IPsec: convert to ahash
Date: Fri, 17 Jul 2009 09:42:39 +0200
Message-ID: <20090717074239.GY20288@secunet.com>
References: <20090716111548.GP20288@secunet.com> <20090716154614.GA4389@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090716154614.GA4389@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 16, 2009 at 11:46:14PM +0800, Herbert Xu wrote:
> 
> My suggestion would be to optimise for the common case, where
> assoc is a single-entry list.  So just put some space aside in
> the request context for a two-entry sg list and copy the assoc
> sg entry into it and chain it with the rest.
> 

Ok, I updated the authenc part in this manner. The authenc part does
not depend on networking changes anymore, so I'll resend it just to
linux-crypto.
