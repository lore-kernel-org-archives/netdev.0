From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: honor IPV6_PKTINFO with v4 mapped
 addresses on sendmsg
Date: Wed, 19 Feb 2014 16:28:56 -0500 (EST)
Message-ID: <20140219.162856.1616257950422736643.davem@davemloft.net>
References: <20140218203808.GA19788@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gert@space.net, tore@fud.no
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46923 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751299AbaBSV26 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Feb 2014 16:28:58 -0500
In-Reply-To: <20140218203808.GA19788@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 18 Feb 2014 21:38:08 +0100

> In case we decide in udp6_sendmsg to send the packet down the ipv4
> udp_sendmsg path because the destination is either of family AF_INET or
> the destination is an ipv4 mapped ipv6 address, we don't honor the
> maybe specified ipv4 mapped ipv6 address in IPV6_PKTINFO.
> 
> We simply can check for this option in ip_cmsg_send because no calls to
> ipv6 module functions are needed to do so.
> 
> Reported-by: Gert Doering <gert@space.net>
> Cc: Tore Anderson <tore@fud.no>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Looks great, applied, thanks Hannes.
