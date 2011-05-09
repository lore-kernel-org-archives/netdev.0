From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] vlan: remove one synchronize_net() call
Date: Mon, 09 May 2011 11:42:14 -0700 (PDT)
Message-ID: <20110509.114214.104063134.davem@davemloft.net>
References: <1304948155.3342.32.camel@edumazet-laptop>
	<1304952044.3342.42.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, kaber@trash.net, netdev@vger.kernel.org,
	paulmck@linux.vnet.ibm.com, jesse@nicira.com,
	mirq-linux@rere.qmqm.pl
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54145
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753474Ab1EISmq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 14:42:46 -0400
In-Reply-To: <1304952044.3342.42.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 09 May 2011 16:40:44 +0200

> At VLAN dismantle phase, unregister_vlan_dev() makes one
> synchronize_net() call after vlan_group_set_device(grp, vlan_id, NULL).
> 
> This call can be safely removed because we are calling
> unregister_netdevice_queue() to queue device for deletion, and this
> process needs at least one rcu grace period to complete.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
