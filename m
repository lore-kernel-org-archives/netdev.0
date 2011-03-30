From: David Miller <davem@davemloft.net>
Subject: Re: [V4] dev : fix mtu check when TSO is enabled
Date: Wed, 30 Mar 2011 02:42:31 -0700 (PDT)
Message-ID: <20110330.024231.57465584.davem@davemloft.net>
References: <1301478035-324-1-git-send-email-daniel@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, eric.dumazet@gmail.com, kaber@trash.net,
	nightnord@gmail.com, netdev@vger.kernel.org
To: daniel@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51663
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932184Ab1C3JnJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2011 05:43:09 -0400
In-Reply-To: <1301478035-324-1-git-send-email-daniel@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <daniel@free.fr>
Date: Wed, 30 Mar 2011 11:40:35 +0200

> From: Daniel Lezcano <daniel.lezcano@free.fr>
> 
> In case the device where is coming from the packet has TSO enabled,
> we should not check the mtu size value as this one could be bigger
> than the expected value.
> 
> This is the case for the macvlan driver when the lower device has
> TSO enabled. The macvlan inherit this feature and forward the packets
> without fragmenting them. Then the packets go through dev_forward_skb
> and are dropped. This patch fix this by checking TSO is not enabled
> when we want to check the mtu size.
> 
> Signed-off-by: Daniel Lezcano <daniel.lezcano@free.fr>
> Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>

Applied.
