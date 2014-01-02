From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv4: introduce ip_dst_mtu_secure and protect forwarding path against pmtu spoofing
Date: Thu, 2 Jan 2014 18:57:17 +0100
Message-ID: <20140102175717.GG22494@order.stressinduktion.org>
References: <20131219000759.GF3505@order.stressinduktion.org> <20131219.001203.1942468169345523058.davem@davemloft.net> <20131219121757.GD14429@order.stressinduktion.org> <20131219.143012.205185984019527730.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: johnwheffner@gmail.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:35635 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750993AbaABR5S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 12:57:18 -0500
Content-Disposition: inline
In-Reply-To: <20131219.143012.205185984019527730.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 19, 2013 at 02:30:12PM -0500, David Miller wrote:
> No end host should have rp_filter on.  It unnecessarily makes our
> routing lookups much more expensive for zero gain on an end host.  But
> people convinced the distributions that turning it on everywhere by
> default was a good idea and it stuck.

Just was thinking about that again when reading the quote on lwn:

Maybe distributions just wanted to be always on the safe side.  As there
is no easy conditional system to enable rp_filter in case a user enables
forwarding, maybe something like

rp_filter:
0 - disable
1 - enable only in case of forwarding
2 - always enable

could be helpful?

I guess it is too late to change this.

Greetings,

  Hannes
