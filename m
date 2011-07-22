From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPv6: autoconfiguration and suspend/resume or link down/up
Date: Fri, 22 Jul 2011 17:21:59 +0800
Message-ID: <20110722092159.GA20722@gondor.apana.org.au>
References: <20110719180222.GA7509@midget.suse.cz> <20110722.010628.1678943945721626312.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jbohac@suse.cz, netdev@vger.kernel.org, shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:50574 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752301Ab1GVJWJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2011 05:22:09 -0400
Content-Disposition: inline
In-Reply-To: <20110722.010628.1678943945721626312.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 22, 2011 at 01:06:28AM -0700, David Miller wrote:
> 
> Suspend is even more important because while we were suspended we
> could be on the same network but the routers present and available
> might have changed completely.

Unfortunately virtual machine live migration also uses the suspend
& resume mechanism.  In that case we don't wish to renegotiate
everything, since the goal is to minimise the outage window.

This would suggest that putting the policy in user-space may be the
best option.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
