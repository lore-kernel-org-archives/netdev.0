From: David Miller <davem@davemloft.net>
Subject: Re: mac80211 truesize bugs
Date: Thu, 01 May 2008 03:53:35 -0700 (PDT)
Message-ID: <20080501.035335.216935614.davem@davemloft.net>
References: <20080501.024320.212547875.davem@davemloft.net>
	<E1JrW9h-0001tI-00@gondolin.me.apana.org.au>
	<20080501.034950.261408566.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, mb@bu3sch.de, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54986
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752961AbYEAKxi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2008 06:53:38 -0400
In-Reply-To: <20080501.034950.261408566.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Thu, 01 May 2008 03:49:50 -0700 (PDT)

> I guess it's the pskb_expand_head() calls done by net/mac80211/tx.c
> I suspect we'll need to orphan early in order to accomodate these
> adjustments, otherwise socket memory buffer allocations will
> be corrupted.

I think the mac80211 encryption paths on TX could be doing this as
well, just something I noticed meanwhile.

