From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vlan: Fix lockdep warning when vlan dev
 handle notification
Date: Fri, 07 Mar 2014 01:49:32 -0500 (EST)
Message-ID: <20140307.014932.157368387111603644.davem@davemloft.net>
References: <5318828D.3090308@huawei.com>
	<20140306.145126.497070034648321818.davem@davemloft.net>
	<5319270D.4030602@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, john.r.fastabend@intel.com, kaber@trash.net,
	netdev@vger.kernel.org, f.fainelli@gmail.com
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36558 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751057AbaCGGti (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 01:49:38 -0500
In-Reply-To: <5319270D.4030602@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Fri, 7 Mar 2014 09:55:25 +0800

> But I think if I vconfig add eth2.20.30 50, the warning would happen
> again, but till now I could not find any scene that use 3 vlan id on
> a virtual device, so I think it is not a problem.

My example was to show that you aren't really fixing the bug, but
rather are papering over it.

In that sense, it is a problem.

I also happen to disagree with your assertion that a 3 layered
VLAN is invalid, it is valid.  And if we allow the configuration
it shouldn't throw locking assertions.
