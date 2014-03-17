From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/10] netpoll: Cleanup received packet processing
Date: Mon, 17 Mar 2014 15:49:16 -0400 (EDT)
Message-ID: <20140317.154916.2276987764507311378.davem@davemloft.net>
References: <20140314.225923.61318448733570839.davem@davemloft.net>
	<87k3bwqgf7.fsf@xmission.com>
	<877g7wqg8e.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42109 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750706AbaCQTtU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 15:49:20 -0400
In-Reply-To: <877g7wqg8e.fsf_-_@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Fri, 14 Mar 2014 20:43:13 -0700

> This is the long-winded, careful, and polite version of removing the netpoll
> receive packet processing.
> 
> First I untangle the code in small steps.  Then I modify the code to not
> force reception and dropping of packets when we are transmiting a packet
> with netpoll.  Finally I move all of the packet reception under
> CONFIG_NETPOLL_TRAP and delete CONFIG_NETPOLL_TRAP.
> 
> If someone wants to do a stable backport of these patches, it would
> require backporting the first 18 patches that handle the budget == 0 in
> the networking drivers, and the first 6 of these patches.
> 
> If anyone wants to resurrect netpoll packet reception someday it should
> just be a matter of reverting the last patch.

Series applied, thanks Eric.
