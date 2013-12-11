From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net_sched: add messages to distinguish errors
 when modify qdisc
Date: Tue, 10 Dec 2013 21:39:43 -0500 (EST)
Message-ID: <20131210.213943.2076281583129546141.davem@davemloft.net>
References: <1386665340-16820-1-git-send-email-yangyingliang@huawei.com>
	<20131210.134702.693746793840315797.davem@davemloft.net>
	<52A7CFCD.5010906@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yangyingliang@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53805 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750829Ab3LKCjp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 21:39:45 -0500
In-Reply-To: <52A7CFCD.5010906@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Yingliang <yangyingliang@huawei.com>
Date: Wed, 11 Dec 2013 10:37:01 +0800

> Then how about change the errno, is that ok ?

No, it will break existing code.

This is really an old topic which has been discussed before.

The problem is that signalling a single integer for errors is
not sufficient enough to transmit the necessary information
to the user.

You have to therefore think more largely about this problem than
trying to fix it easily with some error code adjustments.  The
problem is fundamentally that we only return error codes to
userspace, rather than something more sophisticated.
