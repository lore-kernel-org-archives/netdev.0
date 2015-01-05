From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH/RFC rocker-net-next 1/6] net: flow: Cancel innermost
 nested attribute first
Date: Mon, 05 Jan 2015 17:10:03 -0500 (EST)
Message-ID: <20150105.171003.1816434748443547853.davem@davemloft.net>
References: <1420440610-20621-2-git-send-email-simon.horman@netronome.com>
	<20150105.161725.1765207203472571760.davem@davemloft.net>
	<20150105220113.GD31637@casper.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: simon.horman@netronome.com, john.fastabend@gmail.com,
	netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32992 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754243AbbAEWKK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 17:10:10 -0500
In-Reply-To: <20150105220113.GD31637@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Mon, 5 Jan 2015 22:01:13 +0000

> Thinking about this I'll send a patch to WARN() in nlmsg_trim() on
> mark < skb->data.

+1
