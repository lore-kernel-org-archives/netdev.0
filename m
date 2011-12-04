From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: tcp_sendmsg() page recycling
Date: Sun, 04 Dec 2011 13:14:35 -0500 (EST)
Message-ID: <20111204.131435.1069690930869011475.davem@davemloft.net>
References: <1323018317.2762.143.camel@edumazet-laptop>
	<1323020212.2762.147.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38033 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753092Ab1LDSOi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2011 13:14:38 -0500
In-Reply-To: <1323020212.2762.147.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 04 Dec 2011 18:36:52 +0100

> Definitely worth the pain, isnt it ?

As long as such gains aren't lost in the noise when talking over
real devices.

I'm not a big fan of tbench over loopback numbers, frankly :-)
