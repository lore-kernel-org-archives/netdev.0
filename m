From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] 3c59x: sparse warning fix
Date: Wed, 5 Sep 2007 21:22:35 +0200
Message-ID: <20070905192235.GA1507@electric-eye.fr.zoreil.com>
References: <20070905152359.26215f89@oldman> <1189011425.13308.30.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	klassert@mathematik.tu-chemnitz.de, Jeff Garzik <jeff@garzik.org>,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:36184 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756246AbXIET0G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Sep 2007 15:26:06 -0400
Content-Disposition: inline
In-Reply-To: <1189011425.13308.30.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches <joe@perches.com> :
[...]
> Shouldn't this be:
> 
> 	if (pkt_len < rx_copybreak) {
> 		skb = dev_alloc_skb(pkt_len + 2);
> 		if (!skb) {
> 			bad_news! (like the refill rx ring buffers block)
> 		}

It is not that bad a news: the rx_copybreak optimization is lost but it
is still possible to push the data up the stack.

-- 
Ueimor
