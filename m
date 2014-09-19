From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net] macvlan: allow to enqueue broadcast pkt on virtual
 device
Date: Sat, 20 Sep 2014 07:31:08 +0800
Message-ID: <20140919233108.GA31226@gondor.apana.org.au>
References: <1410941288-1880-1-git-send-email-nicolas.dichtel@6wind.com>
 <20140919.160351.1490731758266834534.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:34808 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756996AbaISXbT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 19:31:19 -0400
Content-Disposition: inline
In-Reply-To: <20140919.160351.1490731758266834534.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 19, 2014 at 04:03:51PM -0400, David Miller wrote:
> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Date: Wed, 17 Sep 2014 10:08:08 +0200
> 
> > Since commit 412ca1550cbe ("macvlan: Move broadcasts into a work queue"), the
> > driver uses tx_queue_len of the master device as the limit of packets enqueuing.
> > Problem is that virtual drivers have this value set to 0, thus all broadcast
> > packets were rejected.
> > Because tx_queue_len was arbitrarily chosen, I replace it with a static limit
> > of 1000 (also arbitrarily chosen).
> > 
> > CC: Herbert Xu <herbert@gondor.apana.org.au>
> > Reported-by: Thibaut Collet <thibaut.collet@6wind.com>
> > Suggested-by: Thibaut Collet <thibaut.collet@6wind.com>
> > Tested-by: Thibaut Collet <thibaut.collet@6wind.com>
> > Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> 
> Herbert please review.

While it would be nice to maintain the ability to chnge this
parameter, I'm fine with this patch as it stands since it fixes
a real regression.

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
