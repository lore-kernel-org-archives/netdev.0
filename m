From: David Miller <davem@davemloft.net>
Subject: Re: [VLAN 03/05]: Fix promiscous/allmulti synchronization races
Date: Sat, 14 Jul 2007 18:53:11 -0700 (PDT)
Message-ID: <20070714.185311.45515372.davem@davemloft.net>
References: <20070712181338.13849.74894.sendpatchset@localhost.localdomain>
	<20070712181343.13849.57866.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, greearb@candelatech.com
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50163
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759848AbXGOBxJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jul 2007 21:53:09 -0400
In-Reply-To: <20070712181343.13849.57866.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 12 Jul 2007 20:13:44 +0200 (MEST)

> [VLAN]: Fix promiscous/allmulti synchronization races
> 
> The set_multicast_list function may be called without holding the rtnl
> mutex, resulting in races when changing the underlying device's promiscous
> and allmulti state. Use the change_rx_mode hook, which is always invoked
> under the rtnl.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied.
