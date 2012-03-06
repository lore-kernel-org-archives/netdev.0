From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] IPv6: Fix not join all-router mcast group when
 forwarding set.
Date: Tue, 06 Mar 2012 17:00:11 -0500 (EST)
Message-ID: <20120306.170011.1150880914651371293.davem@davemloft.net>
References: <4F548D59.1060600@cn.fujitsu.com>
	<20120305.151125.1618240418198694711.davem@davemloft.net>
	<4F555E1D.8020008@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lw@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40210 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965203Ab2CFWAS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 17:00:18 -0500
In-Reply-To: <4F555E1D.8020008@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Wei <lw@cn.fujitsu.com>
Date: Tue, 06 Mar 2012 08:45:17 +0800

> When forwarding was set and a new net device is register,
> we need add this device to the all-router mcast group.
> 
> Signed-off-by: Li Wei <lw@cn.fujitsu.com>

Ok, since all the necessary code paths hold the rtnl mutex, this should
be safe and race free.

Applied, thanks.
