From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 11316] New: severe performance regression for
 iptables nat routing
Date: Fri, 15 Aug 2008 14:55:19 -0700 (PDT)
Message-ID: <20080815.145519.76744504.davem@davemloft.net>
References: <20080815081442.GA20971@gondor.apana.org.au>
	<20080815103235.GA31963@gondor.apana.org.au>
	<20080815105318.GA5590@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.williamson@hp.com, kaber@trash.net, akpm@linux-foundation.org,
	buytenh@marvell.com, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54100
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755209AbYHOVzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2008 17:55:19 -0400
In-Reply-To: <20080815105318.GA5590@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 15 Aug 2008 20:53:18 +1000

> net: Preserve netfilter attributes in skb_gso_segment using __copy_skb_header
> 
> skb_gso_segment didn't preserve some attributes in the original skb
> such as the netfilter fields.  This was harmless until they were used
> which is the case for packets going through lo.
> 
> This patch makes it call __copy_skb_header which also picks up some
> other missing attributes.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
