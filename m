From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 03/25] sja1000: don't use [delayed_]work_pending()
Date: Sat, 22 Dec 2012 00:01:11 -0800 (PST)
Message-ID: <20121222.000111.1132195626602429566.davem@davemloft.net>
References: <1356141435-17340-1-git-send-email-tj@kernel.org>
	<1356141435-17340-4-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, wg@grandegger.com,
	netdev@vger.kernel.org
To: tj@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49145 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799Ab2LVIBO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Dec 2012 03:01:14 -0500
In-Reply-To: <1356141435-17340-4-git-send-email-tj@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tejun Heo <tj@kernel.org>
Date: Fri, 21 Dec 2012 17:56:53 -0800

> There's no need to test whether a (delayed) work item in pending
> before queueing, flushing or cancelling it.  Most uses are unnecessary
> and quite a few of them are buggy.
> 
> Remove unnecessary pending tests from sja1000.  Only compile tested.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Wolfgang Grandegger <wg@grandegger.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: netdev@vger.kernel.org
> ---
> Please let me know how this patch should be routed.  I can take it
> through the workqueue tree if necessary.

I would suggest just taking it via the workqueue tree, thanks Tejun.
