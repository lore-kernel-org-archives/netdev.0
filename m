From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netpoll: fix rx_hook() interface by passing the skb
Date: Tue, 22 Oct 2013 15:40:53 -0400 (EDT)
Message-ID: <20131022.154053.1416934290350706764.davem@davemloft.net>
References: <20131022101127.GJ1544@neomailbox.net>
	<AE90C24D6B3A694183C094C60CF0A2F6026B739F@saturn3.aculab.com>
	<20131022171314.GL1544@neomailbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Laight@ACULAB.COM, netdev@vger.kernel.org
To: antonio@meshcoding.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59152 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754410Ab3JVTk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Oct 2013 15:40:56 -0400
In-Reply-To: <20131022171314.GL1544@neomailbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@meshcoding.com>
Date: Tue, 22 Oct 2013 19:13:14 +0200

> If we go for the "no udp port" approach they will get an error any
> way because of the mismatching arguments.

Antonio, I think it is fair enough to keep passing the port argument
as well as the length.

These precomputed values might as well be provided the to receiver.

Thanks.
