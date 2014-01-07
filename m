From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5] IPv6: add the option to use anycast
 addresses as source addresses in echo reply
Date: Tue, 07 Jan 2014 15:52:03 -0500 (EST)
Message-ID: <20140107.155203.1722933383519867782.davem@davemloft.net>
References: <1389103047-3380-1-git-send-email-fx.lebail@yahoo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: fx.lebail@yahoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44564 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753896AbaAGUwF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 15:52:05 -0500
In-Reply-To: <1389103047-3380-1-git-send-email-fx.lebail@yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
Date: Tue,  7 Jan 2014 14:57:27 +0100

> This change allows to follow a recommandation of RFC4942.
> 
> - Add "anycast_src_echo_reply" sysctl to control the use of anycast addresses
>   as source addresses for ICMPv6 echo reply. This sysctl is false by default
>   to preserve existing behavior.
> - Add inline check ipv6_anycast_destination().
> - Use them in icmpv6_echo_reply().
> 
> Reference:
> RFC4942 - IPv6 Transition/Coexistence Security Considerations
>    (http://tools.ietf.org/html/rfc4942#section-2.1.6)
> 
> 2.1.6. Anycast Traffic Identification and Security
> 
>    [...]
>    To avoid exposing knowledge about the internal structure of the
>    network, it is recommended that anycast servers now take advantage of
>    the ability to return responses with the anycast address as the
>    source address if possible.
> 
> Signed-off-by: Francois-Xavier Le Bail <fx.lebail@yahoo.com>

Looks good, applied, thanks.
