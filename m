From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/core: Save the port number a netdevice uses
Date: Wed, 26 May 2010 01:39:26 -0700 (PDT)
Message-ID: <20100526.013926.28807066.davem@davemloft.net>
References: <20100526081702.GA17160@mtldesk030.lab.mtl.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	rdreier@cisco.com, yevgenyp@mellanox.co.il
To: eli@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48358
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751654Ab0EZIjQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 May 2010 04:39:16 -0400
In-Reply-To: <20100526081702.GA17160@mtldesk030.lab.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cohen <eli@mellanox.co.il>
Date: Wed, 26 May 2010 11:17:02 +0300

> Today, there are no means to know which port of a hardware device a netdev
> interface uses. This patch adds a new field to struct net_device that is used
> to store this value. The network driver should use the SET_NETDEV_PORT_NUM()
> macro to set the port number for the device it manages. For drivers that do not
> set a value, a default value of 1 is set at alloc_netdev_mq().
> This patch also makes use of this feature in the mlx4_en driver.
> 
> Signed-off-by: Eli Cohen <eli@mellanox.co.il>

We have an existing dev_id, use it.
