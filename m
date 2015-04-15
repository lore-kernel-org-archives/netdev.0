From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: ip_tunnel: Remove gratuitous skb scrubbing
Date: Wed, 15 Apr 2015 18:13:59 +0800
Message-ID: <20150415101359.GA3820@gondor.apana.org.au>
References: <20150415100107.GA3655@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:56937 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751399AbbDOKOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 06:14:04 -0400
Content-Disposition: inline
In-Reply-To: <20150415100107.GA3655@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 15, 2015 at 06:01:07PM +0800, Herbert Xu wrote:
> The commit ea23192e8e577dfc51e0f4fc5ca113af334edff9 ("tunnels:
> harmonize cleanup done on skb on rx path") broke anyone trying to
> use netfilter marking across IPv4 tunnels.  As the commit message
> did not give any justification for this (in fact it shouldn't
> even be touching the tx path), I can only assume that it was a typo.
> 
> This patch reverts that change.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Scratch this, I guess most of the scurbbing makes sense.  I'll
spin a patch to just preserves the mark.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
