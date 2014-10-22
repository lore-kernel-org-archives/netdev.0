From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 1/2] ip6_tunnel: put ip6tnl0 FB device into 'any'
 mode
Date: Wed, 22 Oct 2014 12:47:59 -0400 (EDT)
Message-ID: <20141022.124759.127380581033792550.davem@davemloft.net>
References: <1413879088-13513-1-git-send-email-alan@al-an.info>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: alan@al-an.info
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59475 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751445AbaJVQsE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 12:48:04 -0400
In-Reply-To: <1413879088-13513-1-git-send-email-alan@al-an.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Alexey Andriyanov" <alan@al-an.info>
Date: Tue, 21 Oct 2014 12:11:27 +0400

> The fallback device is in ipv6 mode by default.
> The mode can not be changed in runtime, so there
> is no way to decapsulate ip4in6 packets coming from
> various sources without creating the specific tunnel
> ifaces for each peer.
> 
> Cc: David Miller <davem@davemloft.net>
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Alexey Andriyanov <alan@al-an.info>

I don't think you can legitimately change this after all
these years.  You'll break someone's setup somehow.

You're going to have to find a way to achieve what you
want whilst keeping the default unchanged.

Sorry.
