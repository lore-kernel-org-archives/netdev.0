From: David Miller <davem@davemloft.net>
Subject: Re: ipx: fix locking regression in ipx_sendmsg and ipx_recvmsg
Date: Tue, 18 Nov 2014 15:49:44 -0500 (EST)
Message-ID: <20141118.154944.459070848595088193.davem@davemloft.net>
References: <20141117013448.GA26743@midget.suse.cz>
	<8698539.evYG7fs8jS@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbohac@suse.cz, acme@ghostprotocols.net, netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56760 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754856AbaKRUtq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2014 15:49:46 -0500
In-Reply-To: <8698539.evYG7fs8jS@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 18 Nov 2014 14:37:26 +0100

> Does ipxrtr_route_packet() actually sleep while waiting for the network,
> or is it possible that you only need to change the recvmsg path?

I went over that code path and it doesn't appear to sleep at all.
