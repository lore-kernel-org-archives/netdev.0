From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6: Fix not join all-router mcast group when
 forwarding set.
Date: Mon, 05 Mar 2012 15:11:25 -0500 (EST)
Message-ID: <20120305.151125.1618240418198694711.davem@davemloft.net>
References: <4F548D59.1060600@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lw@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55782 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757549Ab2CEULc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 15:11:32 -0500
In-Reply-To: <4F548D59.1060600@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Wei <lw@cn.fujitsu.com>
Date: Mon, 05 Mar 2012 17:54:33 +0800

> +	/* Join all-router multicast group if forwarding is set */
> +        if (ndev->cnf.forwarding && dev && (dev->flags & IFF_MULTICAST))
> +		ipv6_dev_mc_inc(dev, &in6addr_linklocal_allrouters);

Whitespace damaged.  First line properly uses a TAB, the next uses
spaces and indents too far.
