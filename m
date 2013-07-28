From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH] atl1c: Fix misuse of netdev_alloc_skb in refilling
 rx ring
Date: Sat, 27 Jul 2013 20:02:05 -0700 (PDT)
Message-ID: <20130727.200205.67471633133830510.davem@davemloft.net>
References: <87k3kbdcmy.fsf@canonical.com>
	<1374960610.3607.13.camel@deadeye.wl.decadent.org.uk>
	<1374969583.3669.23.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, luis.henriques@canonical.com,
	nhorman@tuxdriver.com, netdev@vger.kernel.org, jcliburn@gmail.com,
	stable@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52002 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753007Ab3G1DCG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Jul 2013 23:02:06 -0400
In-Reply-To: <1374969583.3669.23.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 27 Jul 2013 16:59:43 -0700

> If a hardware needs frame being in a single 4K page, its driver must do
> its own allocation, or add appropriate aligning logic.

Whatever the cause the original patch in this thread is not the
correct fix and I've thus reverted it.
