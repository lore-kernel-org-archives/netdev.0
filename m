From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Glibc recvmsg from kernel netlink socket hangs forever
Date: Fri, 25 Sep 2015 12:58:53 +0800
Message-ID: <20150925045853.GA5286@gondor.apana.org.au>
References: <C3C03EFC-53E1-45DE-87AF-59C7367BD21E@gmail.com>
 <20150925043653.GA29111@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steven Schlansker <stevenschlansker@gmail.com>,
	linux-kernel@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	netdev@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:54987 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750816AbbIYE7C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 00:59:02 -0400
Content-Disposition: inline
In-Reply-To: <20150925043653.GA29111@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 24, 2015 at 09:36:53PM -0700, Guenter Roeck wrote:
>
> http://comments.gmane.org/gmane.linux.network/363085
> 
> might explain your problem.
> 
> I thought this was resolved in 4.1, but it looks like the problem still persists
> there. At least I have reports from my workplace that 4.1.6 and 4.1.7 are still
> affected. I don't know if there have been any relevant changes in 4.2.
> 
> Copying Herbert and Eric for additional input.

There was a separate bug discovered by Tejun recently.  You need
to apply the patches

https://patchwork.ozlabs.org/patch/519245/
https://patchwork.ozlabs.org/patch/520824/

There is another follow-up but it shouldn't make any difference
in practice.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
