From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 3/3 v3] bridge: use rx_handler_data
 pointer to store net_bridge_port pointer
Date: Tue, 15 Jun 2010 11:50:11 -0700 (PDT)
Message-ID: <20100615.115011.229753727.davem@davemloft.net>
References: <20100610133628.GF2618@psychotron.lab.eng.brq.redhat.com>
	<20100615132833.GB3797@psychotron.lab.eng.brq.redhat.com>
	<20100615165043.GA2623@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, kaber@trash.net,
	eric.dumazet@gmail.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41574
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758383Ab0FOSt7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 14:49:59 -0400
In-Reply-To: <20100615165043.GA2623@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Tue, 15 Jun 2010 18:50:45 +0200

> Register net_bridge_port pointer as rx_handler data pointer. As br_port is
> removed from struct net_device, another netdev priv_flag is added to indicate
> the device serves as a bridge port. Also rcuized pointers are now correctly
> dereferenced in br_fdb.c and in netfilter parts.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied.
