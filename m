From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 1/2] net: Get rid of rtnl_link_stats64 /
 net_device_stats union
Date: Thu, 08 Jul 2010 23:46:56 -0700 (PDT)
Message-ID: <20100708.234656.27794492.davem@davemloft.net>
References: <1278631762.16013.307.camel@achroite.uk.solarflarecom.com>
	<1278649543.2435.105.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35825
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752093Ab0GIGql (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 02:46:41 -0400
In-Reply-To: <1278649543.2435.105.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 09 Jul 2010 06:25:43 +0200

> This could be a small helper function, to hide the sizeof(*storage) /
> sizeof(u64) magic..
> 
> static void stats_to_stats64(struct rtnl_link_stats64 *dst,
> 			     const net_device_stats *src)
> {

Ben, please add Eric' suggestion and respin your second patch as
well.

Thanks!
