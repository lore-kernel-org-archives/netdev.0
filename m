From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] ipv6: enable anycast addresses as source
 addresses for datagrams
Date: Wed, 22 Jan 2014 21:57:50 -0800 (PST)
Message-ID: <20140122.215750.1371886476356092894.davem@davemloft.net>
References: <1390361450-3198-1-git-send-email-fx.lebail@yahoo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	dlstevens@us.ibm.com
To: fx.lebail@yahoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54111 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750927AbaAWF5v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 00:57:51 -0500
In-Reply-To: <1390361450-3198-1-git-send-email-fx.lebail@yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
Date: Wed, 22 Jan 2014 04:30:50 +0100

> This change allows to consider an anycast address valid as source address
> when given via an IPV6_PKTINFO or IPV6_2292PKTINFO ancillary data item.
> So, when sending a datagram with ancillary data, the unicast and anycast
> addresses are handled in the same way.
> 
> - Adds ipv6_chk_acast_addr_src() to check if an anycast address is link-local
>   on given interface or is global.
> - Uses it in ip6_datagram_send_ctl().
> 
> Signed-off-by: Francois-Xavier Le Bail <fx.lebail@yahoo.com>

Applied.
