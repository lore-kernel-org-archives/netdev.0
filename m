From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 net-next-2.6] vlan: Precise RX stats accounting
Date: Tue, 17 Nov 2009 23:53:23 -0800 (PST)
Message-ID: <20091117.235323.15113392.davem@davemloft.net>
References: <4B01558F.5000306@gmail.com>
	<20091117.002037.229474882.davem@davemloft.net>
	<4B02B8D5.8040402@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36619
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751732AbZKRHxG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2009 02:53:06 -0500
In-Reply-To: <4B02B8D5.8040402@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 17 Nov 2009 15:53:09 +0100

> Given that vlan_setup(struct net_device *) is void and cannot
> return error status, unless using a global variable (ugly),
> or changing all setup() prototypes (oh well...)
> 
> One possibility is to perform the allocation in vlan_dev_init()
> (called from register_netdevice()), and freeing it in vlan_dev_uninit().

That looks fine.

> [PATCH net-next-2.6 take2] vlan: Precise RX stats accounting
 ...
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
