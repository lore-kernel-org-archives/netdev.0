From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] veth: Fix veth_dellink method
Date: Fri, 30 Oct 2009 01:00:38 -0700 (PDT)
Message-ID: <20091030.010038.44719223.davem@davemloft.net>
References: <4AEA8F0F.4030100@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xemul@openvz.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55677
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754629AbZJ3IAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 04:00:14 -0400
In-Reply-To: <4AEA8F0F.4030100@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 30 Oct 2009 08:00:31 +0100

> In commit 23289a37e2b127dfc4de1313fba15bb4c9f0cd5b
> (net: add a list_head parameter to dellink() method),
> I forgot to actually use this parameter in veth_dellink.
> 
> I remember feeling a bit uncomfortable about veth_close(),
> because it does :
> 
> netif_carrier_off(dev);
> netif_carrier_off(priv->peer);
> 
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
