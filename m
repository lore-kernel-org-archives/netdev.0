From: David Miller <davem@davemloft.net>
Subject: Re: [BUG net-next-2.6] vlan, bonding, bnx2 problems
Date: Mon, 19 Jul 2010 09:35:03 -0700 (PDT)
Message-ID: <20100719.093503.236223875.davem@davemloft.net>
References: <957a5becb6e742b6dc3255b68bef3ba8@dondevamos.com>
	<20100718.153910.67919508.davem@davemloft.net>
	<1279545854.2553.37.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, pedro.netdev@dondevamos.com,
	netdev@vger.kernel.org, kaber@trash.net, bhutchings@solarflare.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55838
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S936389Ab0GSQer (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 12:34:47 -0400
In-Reply-To: <1279545854.2553.37.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 19 Jul 2010 15:24:14 +0200

> [RFC net-next-2.6] bonding: fix bond_inet6addr_event() 
> 
> After commit ad1afb0039391 (vlan_dev: VLAN 0 should be treated
> as "no vlan tag" (802.1p packet)),
> bond_inet6addr_event() might be called with a NULL bond->vlgrp pointer, and
> a non empty bond->vlan_list. vlan_group_get_device() is dereferencing a NULL pointer.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

I'll apply this bandaid for now, but yes we need to think more
deeply about this.
