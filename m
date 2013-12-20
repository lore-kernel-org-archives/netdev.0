From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: introduce ip_dst_mtu_secure and protect
 forwarding path against pmtu spoofing
Date: Thu, 19 Dec 2013 19:33:21 -0500 (EST)
Message-ID: <20131219.193321.590144194287655797.davem@davemloft.net>
References: <20131219121757.GD14429@order.stressinduktion.org>
	<20131219.143012.205185984019527730.davem@davemloft.net>
	<20131219235338.GA32129@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnwheffner@gmail.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37151 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753917Ab3LTAdX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 19:33:23 -0500
In-Reply-To: <20131219235338.GA32129@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Fri, 20 Dec 2013 00:53:38 +0100

> I am fine dropping the knob and just unconditionally ignoring the
> pmtu data in the forwarding path? Is that what you wanted to
> suggest?

Quite the contrary, I thought it was clear that I want the default to
be the current behavior.
