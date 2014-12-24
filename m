From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] 3c59x: Fix memory leaks in vortex_open
Date: Tue, 23 Dec 2014 23:10:23 -0500 (EST)
Message-ID: <20141223.231023.800812106245330144.davem@davemloft.net>
References: <20141223154313.GE31876@hmsreliant.think-freely.org>
	<549A212A.60001@163.com>
	<20141224032728.GA20392@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: baijiaju1990@163.com, ebiederm@xmission.com,
	dingtianhong@huawei.com, paul.gortmaker@windriver.com,
	justinvanwijngaarden@gmail.com, netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35882 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750860AbaLXEK1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2014 23:10:27 -0500
In-Reply-To: <20141224032728.GA20392@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Tue, 23 Dec 2014 22:27:28 -0500

> Sooo, fix it.  Add some checks to not delete the timer if its not been
> initalized.  Its really preferable to have a single teardown path and a single
> bringup path if at all possible

Or simply have vortex_up() initialize the two timers before it does
anything else.
