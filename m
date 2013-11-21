From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] net: rework recvmsg handler msg_name and
 msg_namelen logic
Date: Wed, 20 Nov 2013 22:06:50 -0500 (EST)
Message-ID: <20131120.220650.1525331497396672267.davem@davemloft.net>
References: <20131121021422.GA934@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, joe@perches.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38659 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750860Ab3KUDGw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 22:06:52 -0500
In-Reply-To: <20131121021422.GA934@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu, 21 Nov 2013 03:14:22 +0100

> This patch now always passes msg->msg_namelen as 0. recvmsg handlers must
> set msg_namelen to the proper size <= sizeof(struct sockaddr_storage)
> to return msg_name to the user.

These two patches look fantastic, applied and queued up for -stable
thanks!
