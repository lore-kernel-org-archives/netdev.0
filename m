From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: replace hooks in __netif_receive_skb
 V5
Date: Wed, 02 Jun 2010 07:11:42 -0700 (PDT)
Message-ID: <20100602.071142.219752193.davem@davemloft.net>
References: <20100528073345.GD2823@psychotron.redhat.com>
	<20100601082805.1c84b16d@nehalam>
	<20100602075207.GD2603@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, eric.dumazet@gmail.com,
	shemminger@vyatta.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42221
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932403Ab0FBOLd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 10:11:33 -0400
In-Reply-To: <20100602075207.GD2603@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Wed, 2 Jun 2010 09:52:08 +0200

> What this patch does is it removes two receive frame hooks (for bridge and for
> macvlan) from __netif_receive_skb. These are replaced them with a single
> hook for both. It only supports one hook per device because it makes no
> sense to do bridging and macvlan on the same device.
> 
> Then a network driver (of virtual netdev like macvlan or bridge) can register
> an rx_handler for needed net device.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Ok, this looks good to me.  Applied, thanks everyone.
