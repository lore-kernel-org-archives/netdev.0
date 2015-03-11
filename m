From: David Miller <davem@davemloft.net>
Subject: Re: RFC: dsa: add support for multiple CPU ports
Date: Tue, 10 Mar 2015 21:47:52 -0400 (EDT)
Message-ID: <20150310.214752.2031581574859483040.davem@davemloft.net>
References: <20150310204021.GA2740@codeaurora.org>
	<20150310211315.GF10838@lunn.ch>
	<20150310225326.GA12693@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, netdev@vger.kernel.org, linux@roeck-us.net,
	jogo@openwrt.org, f.fainelli@gmail.com
To: mathieu@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35962 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751426AbbCKBr4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 21:47:56 -0400
In-Reply-To: <20150310225326.GA12693@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mathieu Olivari <mathieu@codeaurora.org>
Date: Tue, 10 Mar 2015 15:53:26 -0700

> I was wondering whether it made sense to show counters for both ethN and
> P0 when running "ethtool -S ethN". Or maybe add a new argument to
> ethtool. Else, there is still debugfs but it means the same counters
> will be accessible through ethtool (for PHY ports) and debugfs (for MAC
> ports), which is not very consistent.

debugfs is only for things that are throw away and upon which userspace
cannot depend.
