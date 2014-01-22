From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v4] ipv6: enable anycast addresses as source addresses for datagrams
Date: Wed, 22 Jan 2014 16:03:45 +0100
Message-ID: <20140122150345.GA7269@order.stressinduktion.org>
References: <1390372958-3654-1-git-send-email-fx.lebail@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev <netdev@vger.kernel.org>,
	David Stevens <dlstevens@us.ibm.com>,
	David Miller <davem@davemloft.net>
To: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:58001 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755212AbaAVPDq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 10:03:46 -0500
Content-Disposition: inline
In-Reply-To: <1390372958-3654-1-git-send-email-fx.lebail@yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 22, 2014 at 07:42:37AM +0100, Francois-Xavier Le Bail wrote:
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

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks!
