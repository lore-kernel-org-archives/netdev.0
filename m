From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] infiniband: make sure the src net is infiniband
 when create new link
Date: Fri, 03 Jan 2014 20:39:24 -0500 (EST)
Message-ID: <20140103.203924.418673249346450315.davem@davemloft.net>
References: <1388720025-26472-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wpan@redhat.com
To: liuhangbin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35675 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753967AbaADBj0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 20:39:26 -0500
In-Reply-To: <1388720025-26472-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hangbin Liu <liuhangbin@gmail.com>
Date: Fri,  3 Jan 2014 11:33:45 +0800

> When we create a new infiniband link with uninfiniband device, e.g. `ip link
> add link em1 type ipoib pkey 0x8001`. We will get a NULL pointer dereference
> cause other dev like Ethernet don't have struct ib_device.
> 
> The code path is:
> rtnl_newlink
>   |-- ipoib_new_child_link
>         |-- __ipoib_vlan_add
>               |-- ipoib_set_dev_features
>                     |-- ib_query_device
> 
> Fix this bug by make sure the src net is infiniband when create new link.
> 
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>

Applied, thank you.
