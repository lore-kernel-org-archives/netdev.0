From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] macvlan: add multicast filter
Date: Wed, 06 Feb 2013 16:00:03 -0500 (EST)
Message-ID: <20130206.160003.1038576500046419799.davem@davemloft.net>
References: <1360131770.28557.26.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, greearb@candelatech.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43707 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932082Ab3BFVAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 16:00:05 -0500
In-Reply-To: <1360131770.28557.26.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 05 Feb 2013 22:22:50 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Setting up IPv6 addresses on configurations with many macvlans
> is not really working, as many multicast messages are dropped.
> 
> Add a multicast filter to macvlan to reduce the amount of cloned
> skbs and overhead.
> 
> Successfully tested with 1024 macvlans on one ethernet device.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
