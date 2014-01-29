From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH stable 3.11+] can: bcm: add skb destructor
Date: Tue, 28 Jan 2014 23:46:30 -0800 (PST)
Message-ID: <20140128.234630.1768378245126172951.davem@davemloft.net>
References: <52E833ED.4080006@hartkopp.net>
	<1390953066.28432.26.camel@edumazet-glaptop2.roam.corp.google.com>
	<52E8B053.2030808@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, socketcan@hartkopp.net,
	netdev@vger.kernel.org
To: nautsch2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49327 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750938AbaA2Hqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jan 2014 02:46:31 -0500
In-Reply-To: <52E8B053.2030808@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andre Naujoks <nautsch2@gmail.com>
Date: Wed, 29 Jan 2014 08:40:03 +0100

> Even if this is a bug in the CAN BCM implementation. Your "fix" just
> enabled a user space application to shut down any machine with a kernel
> containing the BUG_ON patch.

Rather, he detected a potential stray pointer reference to freed data
that was caused by the CAN code which would difficult if not
impossible to detect otherwise.

That's even more dangerous, and you should be thanking him.
