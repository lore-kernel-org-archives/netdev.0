From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: restoring IP multicast addresses when restarting the interface.
Date: Mon, 23 Apr 2012 22:14:25 +1000
Message-ID: <20120423121425.GA29883@gondor.apana.org.au>
References: <20120420212533.78903e3a@asterix.rh>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sting.hengli.com.au ([178.18.18.71]:37906 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753415Ab2DWMO2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 08:14:28 -0400
Content-Disposition: inline
In-Reply-To: <20120420212533.78903e3a@asterix.rh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 20, 2012 at 09:25:33PM -0300, Flavio Leitner wrote:
>
> Although the new behavior seems nice and save some user space
> work, I think it was unintentional and likely to be a bug.
> 
> What you guys think?

Are you talking about multicast subscriptions on the interface?

I don't see why they should disappear when the interface goes
down and then comes back up since these ultimately come from
application sockets which continue to exist after a down/up.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
