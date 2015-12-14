From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net] netlink: fix boolean evaluation on bound
Date: Tue, 15 Dec 2015 01:06:42 +0800
Message-ID: <20151214170642.GA4180@gondor.apana.org.au>
References: <1450112125-29848-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:34664 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751787AbbLNRGp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 12:06:45 -0500
Content-Disposition: inline
In-Reply-To: <1450112125-29848-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 14, 2015 at 05:55:25PM +0100, Hannes Frederic Sowa wrote:
> portid may be 0, thus bound will set the flag to false for in-kernel
> created netlink sockets.
> 
> Fixes: da314c9923fed55 ("netlink: Replace rhash_portid with bound")
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
> This patch should not affect anything and is just meant to close this
> loophole in future. I based it on net, but you can also apply it to
> net-next.

Nack.  The bound field only needs to be true for user-space sockets.
So please explain why you need it to be true for kernel sockets.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
