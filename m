From: David Miller <davem@davemloft.net>
Subject: Re: gro: Fix illegal merging of trailer trash
Date: Tue, 17 Nov 2009 05:18:45 -0800 (PST)
Message-ID: <20091117.051845.16811152.davem@davemloft.net>
References: <20091117124414.GA14951@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mwagner@redhat.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41391
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750772AbZKQNS3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 08:18:29 -0500
In-Reply-To: <20091117124414.GA14951@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 17 Nov 2009 20:44:14 +0800

> gro: Fix illegal merging of trailer trash
> 
> When we've merged skb's with page frags, and subsequently receive
> a trailer skb (< MSS) that is not completely non-linear (this can
> occur on Intel NICs if the packet size falls below the threshold),
> GRO ends up producing an illegal GSO skb with a frag_list.
> 
> This is harmless unless the skb is then forwarded through an
> interface that requires software GSO, whereupon the GSO code
> will BUG.
> 
> This patch detects this case in GRO and avoids merging the
> trailer skb.
> 
> Reported-by: Mark Wagner <mwagner@redhat.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, and queued up for -stable, thanks.
