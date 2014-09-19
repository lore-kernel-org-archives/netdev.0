From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: ipsec: Remove obsolete MAX_AH_AUTH_LEN
Date: Fri, 19 Sep 2014 09:48:27 +0200
Message-ID: <20140919074827.GW6390@secunet.com>
References: <20140917045828.GA32086@gondor.apana.org.au>
 <20140918083818.GA13056@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:56409 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751294AbaISHse (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Sep 2014 03:48:34 -0400
Content-Disposition: inline
In-Reply-To: <20140918083818.GA13056@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 18, 2014 at 04:38:18PM +0800, Herbert Xu wrote:
> Oops, should've sent this to Steffen:
> 
> While tracking down the MAX_AH_AUTH_LEN crash in an old kernel
> I thought that this limit was rather arbitrary and we should
> just get rid of it.
> 
> In fact it seems that we've already done all the work needed
> to remove it apart from actually removing it.  This limit was
> there in order to limit stack usage.  Since we've already
> switched over to allocating scratch space using kmalloc, there
> is no longer any need to limit the authentication length.
> 
> This patch kills all references to it, including the BUG_ONs
> that led me here.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to ipsec-next, thanks Herbert!
