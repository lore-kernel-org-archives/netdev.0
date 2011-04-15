From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] ipv6: RTA_PREFSRC support for ipv6 route source
 address selection
Date: Fri, 15 Apr 2011 15:45:44 -0700 (PDT)
Message-ID: <20110415.154544.102557027.davem@davemloft.net>
References: <20110414071057.GB78446@0x90.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: sahne@0x90.at
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36291
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754958Ab1DOWqT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 18:46:19 -0400
In-Reply-To: <20110414071057.GB78446@0x90.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Walter <sahne@0x90.at>
Date: Thu, 14 Apr 2011 09:10:57 +0200

> [ipv6] Add support for RTA_PREFSRC
> 
> This patch allows a user to select the preferred source address
> for a specific IPv6-Route. It can be set via a netlink message
> setting RTA_PREFSRC to a valid IPv6 address which must be
> up on the device the route will be bound to.
> 
> 
> Signed-off-by: Daniel Walter <dwalter@barracuda.com>

Applied to net-next-2.6

> +		err = ip6_route_get_saddr(net, rt, &fl6->daddr, 
                                                                ^^

This line had trailing whitespace, please avoid this in the future
as GIT complains about it and I have to fix it up by hand.
