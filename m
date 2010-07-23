From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Yet another bridge netfilter crash
Date: Fri, 23 Jul 2010 23:00:41 +0800
Message-ID: <20100723150041.GA7301@gondor.apana.org.au>
References: <20100723134208.GA6655@gondor.apana.org.au> <4C49A4C6.4070503@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:60744 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759247Ab0GWPAr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 11:00:47 -0400
Content-Disposition: inline
In-Reply-To: <4C49A4C6.4070503@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 23, 2010 at 04:18:46PM +0200, Patrick McHardy wrote:
>
> I think we've already fixed this by commit 8fa9ff6:
> 

> commit 8fa9ff6849bb86c59cc2ea9faadf3cb2d5223497
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Tue Dec 15 16:59:59 2009 +0100
> 
>     netfilter: fix crashes in bridge netfilter caused by fragment jumps

Thanks for the pointer Patrick.

Your memory is much better than mine, as I was in that thread too :)

BTW, do you have any plans on addressing the deeper issue of
separating the connection tracking as well?

There's also the matter of fragments jumping between bridges.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
