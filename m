From: David Miller <davem@davemloft.net>
Subject: Re: [RFC, VLAN]: Propagate selected feature bits to VLAN devices
Date: Tue, 20 May 2008 14:55:01 -0700 (PDT)
Message-ID: <20080520.145501.13214341.davem@davemloft.net>
References: <4832E223.7020206@trash.net>
	<20080520180528.GU28241@solarflare.com>
	<48331914.7050501@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44730
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762627AbYETVzG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 17:55:06 -0400
In-Reply-To: <48331914.7050501@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 20 May 2008 20:31:48 +0200

> commit fd467a0422c9c8ddd05c53c4f91d4af71c8fb9ff
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Tue May 20 20:31:40 2008 +0200
> 
>     [VLAN]: Propagate selected feature bits to VLAN devices
>     
>     Propagate feature bits from the NETDEV_FEAT_CHANGE notifier. For now
>     only TSO is propagated for devices that announce their ability to
>     support TSO in combination with VLAN accel by setting the NETIF_F_VLAN_TSO
>     flag.
>     
>     Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks Patrick!
