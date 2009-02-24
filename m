From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: VM_BUG_ON triggered with udp6fuzz
Date: Tue, 24 Feb 2009 15:12:28 +0800
Message-ID: <20090224071227.GA20887@gondor.apana.org.au>
References: <20090223142213.GA22327@alice>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Sesterhenn <snakebyte@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:49268 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752190AbZBXHMe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 02:12:34 -0500
Content-Disposition: inline
In-Reply-To: <20090223142213.GA22327@alice>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Sesterhenn <snakebyte@gmx.de> wrote:
> hi,
> 
> first of all, i am not able to replicate this after a clean boot,
> running the command sudo -u snakebyte lf6/udp6fuzz -n 100 -r 9343
> produced the following BUG on my test box
> Not sure where the get_page was triggered from, could not 
> find it in udp6.c ...

It's a weird crash.  The stuff that we do with sk_sndmsg_page on
the UDP path is nonstandard to say the least.  However, it does
look kosher.

So please let us know if you can reproduce this again.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
