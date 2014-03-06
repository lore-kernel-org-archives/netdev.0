From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] bonding: correctly handle out of range parameters
 for lp_interval
Date: Thu, 06 Mar 2014 17:06:49 -0500 (EST)
Message-ID: <20140306.170649.2053437094145326106.davem@davemloft.net>
References: <1394142791-11142-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, vfalico@redhat.com, andy@greyhouse.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	nikolay@redhat.com
To: sasha.levin@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33984 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750834AbaCFWGw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 17:06:52 -0500
In-Reply-To: <1394142791-11142-1-git-send-email-sasha.levin@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sasha Levin <sasha.levin@oracle.com>
Date: Thu,  6 Mar 2014 16:53:11 -0500

> We didn't correctly check cases where the value for lp_interval is not
> within the legal range due to a missing table terminator.
> 
> This would let userspace trigger a kernel panic by specifying a value out
> of range:
> 
> 	echo -1 > /sys/devices/virtual/net/bond0/bonding/lp_interval
> 
> Introduced by commit 4325b374f84 ("bonding: convert lp_interval to use
> the new option API").
> 
> Acked-by: Nikolay Aleksandrov <nikolay@redhat.com>
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

Applied, thanks.
