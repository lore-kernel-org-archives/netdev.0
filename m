From: David Miller <davem@davemloft.net>
Subject: Re: Softirq priority inversion from "softirq: reduce latencies"
Date: Mon, 29 Feb 2016 15:24:27 -0500 (EST)
Message-ID: <20160229.152427.1590219093309278129.davem@davemloft.net>
References: <1456770279.648.85.camel@edumazet-ThinkPad-T530>
	<56D493A5.403@hurleysoftware.com>
	<alpine.DEB.2.11.1602292009430.3638@nanos>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peter@hurleysoftware.com, eric.dumazet@gmail.com,
	umgwanakikbuti@gmail.com, romieu@fr.zoreil.com,
	edumazet@google.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org,
	dmaengine@vger.kernel.org, john.ogness@linutronix.de,
	bigeasy@linutronix.de, akpm@linux-foundation.org
To: tglx@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50625 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750973AbcB2UYc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 15:24:32 -0500
In-Reply-To: <alpine.DEB.2.11.1602292009430.3638@nanos>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Gleixner <tglx@linutronix.de>
Date: Mon, 29 Feb 2016 20:14:36 +0100 (CET)

> On Mon, 29 Feb 2016, Peter Hurley wrote:
>> Or flipping your argument on its head, why not just _always_ execute
>> softirq in ksoftirqd?
> 
> Which is what that change effectivley does. And that makes a lot of sense,
> because you get the softirq load under scheduler control and do not let the
> softirq run as a context stealing entity which is completely uncontrollable by
> the scheduler.

+1
