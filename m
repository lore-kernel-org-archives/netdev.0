From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usbnet: drop unneeded check for NULL
Date: Tue, 04 Sep 2012 12:37:40 -0400 (EDT)
Message-ID: <20120904.123740.1915830868205918256.davem@davemloft.net>
References: <1346768514-19823-1-git-send-email-oliver@neukum.org>
	<20120904155343.GA2170@netboy.at.omicron.at>
	<20747715.9FmHp7X6VE@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, netdev@vger.kernel.org
To: oliver@neukum.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59502 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932415Ab2IDQhm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2012 12:37:42 -0400
In-Reply-To: <20747715.9FmHp7X6VE@linux-lqwf.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oliver@neukum.org>
Date: Tue, 04 Sep 2012 18:13:18 +0200

> If that check is ever needed and tx_fixup not needed, the driver will oops here.
> The check is wrong in any case.

Right, we are dealing with two different things here.

Tree-wide there was a blind set of changes to protect skb_tx_timestamp()
calls with a NULL skb check.

But in this specific case, it's completely unnecessary.

So Oliver's change is definitely correct and I will add it to net-next

Thanks.
