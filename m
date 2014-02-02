From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND net-next v3 0/2] bonding: Fix some issues for
 fail_over_mac
Date: Sat, 01 Feb 2014 16:53:52 -0800 (PST)
Message-ID: <20140201.165352.519882344110165920.davem@davemloft.net>
References: <52E3447B.6050206@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, vfalico@redhat.com, netdev@vger.kernel.org,
	andy@greyhouse.net
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51139 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753438AbaBBAxx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Feb 2014 19:53:53 -0500
In-Reply-To: <52E3447B.6050206@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Sat, 25 Jan 2014 12:58:35 +0800

> The parameter fail_over_mac only affect active-backup mode, if it was
> set to active or follow and works with other modes, just like RR or XOR
> mode, the bonding could not set all slaves to the master's address, it
> will cause the slave could not work well with master.
> 
> v1->v2: According Jay's suggestion, that we should permit setting an option
> 	at any time, but only have it take effect in active-backup mode, so
> 	I add mode checking together with fail_over_mac during enslavement and
> 	rebuild the patches.
> 
> v2->v3: The correct way to fix the problem is that we should not add restrictions when
>     	setting options, just need to modify the bond enslave and removal processing
>     	to check the mode in addition to fail_over_mac when setting a slave's MAC during
>     	enslavement. The change active slave processing already only calls the fail_over_mac
>     	function when in active-backup mode.
> 
> 	Remove the cleanup patch because the net-next is frozen now.

This series has been rotting in patchwork for a week, and desperately
needs someone to review it.
