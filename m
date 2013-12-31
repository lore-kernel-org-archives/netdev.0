From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] ipv4: add forwarding_uses_pmtu knob to
 protect forward path to use pmtu info
Date: Tue, 31 Dec 2013 01:04:03 -0500 (EST)
Message-ID: <20131231.010403.73052460631688921.davem@davemloft.net>
References: <20131220130822.GD32129@order.stressinduktion.org>
	<20131230.222044.884570280065942449.davem@davemloft.net>
	<20131231035247.GA27636@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59034 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750720Ab3LaGEH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Dec 2013 01:04:07 -0500
In-Reply-To: <20131231035247.GA27636@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 31 Dec 2013 04:52:47 +0100

> I am still convinced we should suppress path mtu information in
> forwarding path.

This is why it disappoints me that the person who felt differently,
you left out of the CC: when you reposted your patches.  He's
the person who made the code the way it is right now.
