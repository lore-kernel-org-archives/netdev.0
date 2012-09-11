From: David Miller <davem@davemloft.net>
Subject: Re: GRO aggregation
Date: Tue, 11 Sep 2012 15:35:00 -0400 (EDT)
Message-ID: <20120911.153500.773448380897956568.davem@davemloft.net>
References: <36F7E4A28C18BE4DB7C86058E7B607241E622022@MTRDAG01.mtl.com>
	<1347390113.13103.660.camel@edumazet-glaptop>
	<36F7E4A28C18BE4DB7C86058E7B607241E622083@MTRDAG01.mtl.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: shlomop@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47015 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751824Ab2IKTfF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2012 15:35:05 -0400
In-Reply-To: <36F7E4A28C18BE4DB7C86058E7B607241E622083@MTRDAG01.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shlomo Pongratz <shlomop@mellanox.com>
Date: Tue, 11 Sep 2012 19:24:26 +0000

> I see that in ixgbe the weight for the NAPI is 64
> (netif_napi_add). So if packets are arriving in high rate then an
> the CPU is fast enough to collect the packets as they arrive,
> assuming packets continue to arrives while the NAPI runs. Then it
> should have aggregate more. So we will have less passes trough the
> stack.

Eric is trying to say that that cpu is fast enough that it completely
depletes the pending RX packets, the RX queue is empty, and there is
only 32K worth of GRO to accumulate.

BTW, your email quoting is non-standard and very confusing.  There
is absolutely no delineation between the text that you are writing
and the text of the people you are responding too.  Please learn how
to write email replies properly.

Thank you.
