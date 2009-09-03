From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] vlan: multiqueue vlan devices
Date: Wed, 02 Sep 2009 18:04:01 -0700 (PDT)
Message-ID: <20090902.180401.155663057.davem@davemloft.net>
References: <4A9EBF9C.2030904@gmail.com>
	<20090902120107.15146e4e@nehalam>
	<4A9EC383.4070304@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, brian.haley@hp.com, kaber@trash.net,
	jarkao2@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56523
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753078AbZICBDq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 21:03:46 -0400
In-Reply-To: <4A9EC383.4070304@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 02 Sep 2009 21:12:03 +0200

> [PATCH net-next-2.6] vlan: multiqueue vlan device
> 
> vlan devices are currently not multi-queue capable.
> 
> We can do that with a new rtnl_link_ops method,
> get_tx_queues(), called from rtnl_create_link()
> 
> This new method gets num_tx_queues/real_num_tx_queues
> from real device.
> 
> register_vlan_device() is also handled.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, but now I need you to do an audit :-)

I believe that drivers will change the number of TX queues
in use at times where we'll need to trigger an event or
something so that vlan's can learn about the value changing.
