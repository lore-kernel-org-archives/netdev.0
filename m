From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 0/6] net: Speedup netdevice unregisters
Date: Wed, 28 Oct 2009 02:23:18 -0700 (PDT)
Message-ID: <20091028.022318.155344824.davem@davemloft.net>
References: <4AE7279B.7070300@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36262
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753620AbZJ1JWy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 05:22:54 -0400
In-Reply-To: <4AE7279B.7070300@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 27 Oct 2009 18:02:19 +0100

> netdevice unregisters are serialized and call synchronize_{net|rcu}()
> three times per device.
> 
> This means it can take a long time to remove a device, if many virtual
> devices are attached. (vlan, macvlan, tunnels, ...)
>
> This patch series partially solve the problem by batching several devices in a list,
> so that two synchronize_net() calls can be factorized.

Looks really good Eric.

> PATCH 1/6 : net: Introduce unregister_netdevice_queue()
> PATCH 2/6 : net: Introduce unregister_netdevice_many()
> PATCH 3/6 : net: Add a list_head parameter to dellink() method
> PATCH 4/6 : vlan: Optimize multiple unregistration
> PATCH 5/6 : ipip: Optimize multiple unregistration
> PATCH 6/6 : gre: Optimize multiple unregistration
> 

All applied to net-next-2.6, thanks!
