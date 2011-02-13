From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next-2.6] net: make dev->master general
Date: Sun, 13 Feb 2011 11:08:06 -0800 (PST)
Message-ID: <20110213.110806.13753253.davem@davemloft.net>
References: <20110212164836.GB12156@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	nicolas.2p.debian@gmail.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46771
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754738Ab1BMTHa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Feb 2011 14:07:30 -0500
In-Reply-To: <20110212164836.GB12156@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Sat, 12 Feb 2011 17:48:36 +0100

> dev->master is now tightly connected to bonding driver. This patch makes
> this pointer more general and ready to be used by others.
> 
>  - netdev_set_master() - bond specifics moved to new function
>    netdev_set_bond_master()
>  - introduced netif_is_bond_slave() to check if device is a bonding slave
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied.
