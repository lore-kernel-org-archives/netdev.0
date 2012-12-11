From: David Miller <davem@davemloft.net>
Subject: Re: netdevice wanrouter: Convert directly reference of netdev->priv
Date: Tue, 11 Dec 2012 13:46:09 -0500 (EST)
Message-ID: <20121211.134609.2162096096504478639.davem@davemloft.net>
References: <20121203090405.GA12089@elgon.mountain>
	<20121211.134310.1757064654502486858.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wangchen@cn.fujitsu.com, netdev@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41614 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753769Ab2LKSqL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2012 13:46:11 -0500
In-Reply-To: <20121211.134310.1757064654502486858.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 11 Dec 2012 13:43:10 -0500 (EST)

> What's missing at the top level is something like:
> 
> 	dev = wandev->dev;
> 
> And perhaps removing the 'dev' argument to the ->new_if()
> method since it obviously is always NULL and never actually
> used.

And for the record, wangchen's email bounces so it's very
unlikely we'll see any response from him.
