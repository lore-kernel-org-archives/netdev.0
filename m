From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] icmp: Remove some spurious dropped packet
 profile hits from the ICMP path
Date: Thu, 13 Nov 2014 20:32:12 -0500 (EST)
Message-ID: <20141113.203212.2185322208513784942.davem@davemloft.net>
References: <20141113225457.A3E502900805@tardy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: raj@tardy.usa.hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34292 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934682AbaKNBc0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 20:32:26 -0500
In-Reply-To: <20141113225457.A3E502900805@tardy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: raj@tardy.usa.hp.com (Rick Jones)
Date: Thu, 13 Nov 2014 14:54:57 -0800 (PST)

> +	/* until the v6 path can be better sorted we may still need
> +	 * to kfree_sbk() here but want to avoid a double free from

Typo "kfree_skb()".
