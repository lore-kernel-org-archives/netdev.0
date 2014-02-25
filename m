From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: Fix permission check in netlink_connect()
Date: Tue, 25 Feb 2014 18:36:00 -0500 (EST)
Message-ID: <20140225.183600.689378417138341310.davem@davemloft.net>
References: <1393272676-3188-1-git-send-email-mike.pecovnik@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mike.pecovnik@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58569 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752826AbaBYXgC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 18:36:02 -0500
In-Reply-To: <1393272676-3188-1-git-send-email-mike.pecovnik@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Pecovnik <mike.pecovnik@gmail.com>
Date: Mon, 24 Feb 2014 21:11:16 +0100

> netlink_sendmsg() was changed to prevent non-root processes from sending
> messages with dst_pid != 0.
> netlink_connect() however still only checks if nladdr->nl_groups is set.
> This patch modifies netlink_connect() to check for the same condition.
> 
> Signed-off-by: Mike Pecovnik <mike.pecovnik@gmail.com>

Applied, thank you.
