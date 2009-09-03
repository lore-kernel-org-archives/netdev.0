From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] vlan: multiqueue vlan devices
Date: Thu, 03 Sep 2009 02:20:14 -0700 (PDT)
Message-ID: <20090903.022014.46986115.davem@davemloft.net>
References: <4A9EC383.4070304@gmail.com>
	<20090902.180401.155663057.davem@davemloft.net>
	<4A9F8999.1060404@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, brian.haley@hp.com, kaber@trash.net,
	jarkao2@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46836
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754067AbZICJT7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 05:19:59 -0400
In-Reply-To: <4A9F8999.1060404@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 03 Sep 2009 11:17:13 +0200

> [PATCH net-next-2.6] vlan: enable multiqueue xmits
> 
> vlan_dev_hard_start_xmit() & vlan_dev_hwaccel_hard_start_xmit()
> select txqueue number 0, instead of using index provided by
> skb_get_queue_mapping().
> 
> This is not correct after commit 2e59af3dcbdf11635c03f
> [vlan: multiqueue vlan device] because
> txq->tx_packets  & txq->tx_bytes changes are performed on
> a single location, and not the right locking.
> 
> Fix is to take the appropriate struct netdev_queue pointer
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Details details :-)

Looks good, applied!
