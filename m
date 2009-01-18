From: David Miller <davem@davemloft.net>
Subject: Re: [3/3] gro: Fix merging of paged packets
Date: Sat, 17 Jan 2009 23:04:35 -0800 (PST)
Message-ID: <20090117.230435.142761364.davem@davemloft.net>
References: <20090118054616.GA24899@gondor.apana.org.au>
	<20090118054813.GB24943@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37552
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755747AbZARHEd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2009 02:04:33 -0500
In-Reply-To: <20090118054813.GB24943@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 18 Jan 2009 16:48:13 +1100

> gro: Fix merging of paged packets
> 
> The previous fix to paged packets broke the merging because it
> reset the skb->len before we added it to the merged packet.  This
> wasn't detected because it simply resulted in the truncation of
> the packet while the missing bit is subsequently retransmitted.
> 
> The fix is to store skb->len before we clobber it.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
