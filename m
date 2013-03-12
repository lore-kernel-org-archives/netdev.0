From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 05/22] cxgb4: Add T5 write combining support
Date: Tue, 12 Mar 2013 08:19:27 -0400 (EDT)
Message-ID: <20130312.081927.1036246728528667686.davem@davemloft.net>
References: <1363088794-31453-1-git-send-email-vipul@chelsio.com>
	<1363088794-31453-6-git-send-email-vipul@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-scsi@vger.kernel.org, roland@purestorage.com,
	JBottomley@parallels.com, dm@chelsio.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	naresh@chelsio.com, divy@chelsio.com, santosh@chelsio.com,
	arvindb@chelsio.com, abhishek@chelsio.com
To: vipul@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50785 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755199Ab3CLMTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 08:19:17 -0400
In-Reply-To: <1363088794-31453-6-git-send-email-vipul@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vipul Pandya <vipul@chelsio.com>
Date: Tue, 12 Mar 2013 17:16:17 +0530

> +				writel(n,  adap->bar2 + q->udb + 8);
> +#if defined(CONFIG_X86_32) || defined(CONFIG_X86_64)
> +			asm volatile("sfence" : : : "memory");
> +#endif

There is absolutely no way I'm letting anyone put crap like this
into a driver.

Use a portable inteface, and if one does not exist create one.
