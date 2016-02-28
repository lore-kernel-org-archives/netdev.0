From: David Miller <davem@davemloft.net>
Subject: Re: Softirq priority inversion from "softirq: reduce latencies"
Date: Sat, 27 Feb 2016 23:46:57 -0500 (EST)
Message-ID: <20160227.234657.984787532933890615.davem@davemloft.net>
References: <56D23266.2080306@hurleysoftware.com>
	<1456624766.648.43.camel@edumazet-ThinkPad-T530>
	<56D25713.8050307@hurleysoftware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, edumazet@google.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	gregkh@linuxfoundation.org, dmaengine@vger.kernel.org,
	john.ogness@linutronix.de, bigeasy@linutronix.de,
	akpm@linux-foundation.org
To: peter@hurleysoftware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49463 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992703AbcB1ErD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2016 23:47:03 -0500
In-Reply-To: <56D25713.8050307@hurleysoftware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Hurley <peter@hurleysoftware.com>
Date: Sat, 27 Feb 2016 18:10:27 -0800

> That tasklet should run before any process.

You never have this guarantee, even before Eric's patch.
Under load tasklets run from ksoftirqd just like any other
softirq.

Please fix your driver and stop blaming Eric's change.

Thank you.
