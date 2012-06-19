From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [XFRM][RFC v1] Fix unexpected SA hard expiration after setting
 new date
Date: Tue, 19 Jun 2012 15:43:42 +0800
Message-ID: <20120619074342.GA32309@gondor.apana.org.au>
References: <1340007856-27651-1-git-send-email-fan.du@windriver.com>
 <20120618084021.GA24902@gondor.apana.org.au>
 <20120619.003422.1109786261235176550.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fan.du@windriver.com, netdev@vger.kernel.org, fdu@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sting.hengli.com.au ([178.18.18.71]:58678 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753350Ab2FSHnq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 03:43:46 -0400
Content-Disposition: inline
In-Reply-To: <20120619.003422.1109786261235176550.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 19, 2012 at 12:34:22AM -0700, David Miller wrote:
> 
> But I seem to remember that last time this issue came up the
> suggestion was to use highres timers.  Someone tried but they did an
> amazingly poor job so the effort just died off.  It takes someone with
> some skill because highres timers operate with different context
> requirements than normal timers.

Sorry I think I didn't see that discussion or if I did, then
it has completely left my mind :)

So excuse my ignorance, are highres timers relative like jiffies
or absolute? If it's absolute, I don't see how it would impact this
case.

If it's relative, what exactly does it buy for us over jiffies?

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
