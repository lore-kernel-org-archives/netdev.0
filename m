From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/mlx4: Support shutdown() interface
Date: Wed, 05 Mar 2014 20:45:50 -0500 (EST)
Message-ID: <20140305.204550.930739914330776862.davem@davemloft.net>
References: <1393918520-3268-1-git-send-email-shangw@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	amirv@mellanox.com, weiyang@linux.vnet.ibm.com,
	benh@kernel.crashing.org
To: shangw@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51746 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757611AbaCFBpw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 20:45:52 -0500
In-Reply-To: <1393918520-3268-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gavin Shan <shangw@linux.vnet.ibm.com>
Date: Tue,  4 Mar 2014 15:35:20 +0800

> In kexec scenario, we failed to load the mlx4 driver in the
> second kernel because the ownership bit was hold by the first
> kernel without release correctly.
> 
> The patch adds shutdown() interface so that the ownership can
> be released correctly in the first kernel. It also helps avoiding
> EEH error happened during boot stage of the second kernel because
> of undesired traffic, which can't be handled by hardware during
> that stage on Power platform.
> 
> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
> Tested-by: Wei Yang <weiyang@linux.vnet.ibm.com>

Applied.
