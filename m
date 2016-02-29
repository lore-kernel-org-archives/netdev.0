From: David Miller <davem@davemloft.net>
Subject: Re: Softirq priority inversion from "softirq: reduce latencies"
Date: Mon, 29 Feb 2016 12:16:05 -0500 (EST)
Message-ID: <20160229.121605.1302971583714293773.davem@davemloft.net>
References: <20160228170109.GA16322@electric-eye.fr.zoreil.com>
	<1456721889.3488.67.camel@gmail.com>
	<56D45DAF.5070709@hurleysoftware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: umgwanakikbuti@gmail.com, romieu@fr.zoreil.com,
	edumazet@google.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org,
	dmaengine@vger.kernel.org, john.ogness@linutronix.de,
	bigeasy@linutronix.de, akpm@linux-foundation.org,
	tglx@linutronix.de
To: peter@hurleysoftware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47431 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750871AbcB2RQI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 12:16:08 -0500
In-Reply-To: <56D45DAF.5070709@hurleysoftware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Hurley <peter@hurleysoftware.com>
Date: Mon, 29 Feb 2016 07:03:11 -0800

> However, I'm pointing out that Eric's sledgehammer approach to fixing
> the NET_RX softirq bug is having significant side-effects in other
> subsystems.

Either your hardware can handle arbitrary latencies and thus can use
softirqs for event completion successfully, or it can't.

You, my friend, are the one using the sledgehammer.
