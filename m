From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: only send arp monitor packets if no other
 traffic
Date: Thu, 17 May 2012 20:08:42 -0400 (EDT)
Message-ID: <20120517.200842.2215723188229945074.davem@davemloft.net>
References: <4FB3F67C.6000401@genband.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, netdev@vger.kernel.org
To: chris.friesen@genband.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36355 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932585Ab2ERAIs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 20:08:48 -0400
In-Reply-To: <4FB3F67C.6000401@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Friesen <chris.friesen@genband.com>
Date: Wed, 16 May 2012 12:48:28 -0600

> +		if (IS_UP(slave->dev)) {
> +			if (time_after_eq(jiffies, dev_trans_start(slave->dev) + delta_in_ticks) ||
> +			    time_after_eq(jiffies, slave->dev->last_rx + delta_in_ticks)) {
> +				bond_arp_send_all(bond, slave);
> +			}

These lines are very long, and instead of just reformatting them I'd suggest
that you simply make the test a static helper function.

Also, you should not use braces to enclose a single line of code.

Thanks.
