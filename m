From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] bnx2 + vlan + TSO : doesnt work
Date: Mon, 17 Jan 2011 22:09:27 -0800 (PST)
Message-ID: <20110117.220927.189715926.davem@davemloft.net>
References: <1295308844.3362.135.camel@edumazet-laptop>
	<1295309365.6264.23.camel@bwh-desktop>
	<AANLkTincFt4fKLvtity=MgQ2+cuvNFrBHqu3+bMLsypc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50701
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750923Ab1ARGIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 01:08:53 -0500
In-Reply-To: <AANLkTincFt4fKLvtity=MgQ2+cuvNFrBHqu3+bMLsypc@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Mon, 17 Jan 2011 16:13:18 -0800

> I think it is better for netif_skb_features() to actually return the
> correct features rather than bypass it here.  NETIF_F_HW_VLAN_TX
> doesn't depend on any other offloads, so we can always include it if
> it is in dev->features.
> 
> Separately, this means there is a problem with bnx2 because it allows
> vlan insertion to be turned off, which would have the same effect.
> Maybe it is looking directly at skb->protocol or similar for TSO.

Please, someone cons up an acceptable fix fast.

Thanks.
