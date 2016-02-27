From: David Miller <davem@davemloft.net>
Subject: Re: Softirq priority inversion from "softirq: reduce latencies"
Date: Sat, 27 Feb 2016 18:04:03 -0500 (EST)
Message-ID: <20160227.180403.2101360385050644823.davem@davemloft.net>
References: <56D1E8B6.6090003@hurleysoftware.com>
	<1456604037.648.29.camel@edumazet-ThinkPad-T530>
	<56D20733.1000409@hurleysoftware.com>
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
Received: from shards.monkeyblade.net ([149.20.54.216]:46230 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756778AbcB0XEH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2016 18:04:07 -0500
In-Reply-To: <56D20733.1000409@hurleysoftware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Hurley <peter@hurleysoftware.com>
Date: Sat, 27 Feb 2016 12:29:39 -0800

> Not really. softirq raised from interrupt context will always execute
> on this cpu and not in ksoftirqd, unless load forces softirq loop abort.

That guarantee never was specified.

Or are you saying that by design, on a system under load, your UART
will not function properly?

Surely you don't mean that.
