From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v5] IPv6: add the option to use anycast addresses as source addresses in echo reply
Date: Tue, 7 Jan 2014 20:14:36 +0100
Message-ID: <20140107191436.GE30393@order.stressinduktion.org>
References: <1389103047-3380-1-git-send-email-fx.lebail@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:46015 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751057AbaAGTOh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 14:14:37 -0500
Content-Disposition: inline
In-Reply-To: <1389103047-3380-1-git-send-email-fx.lebail@yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 07, 2014 at 02:57:27PM +0100, Francois-Xavier Le Bail wrote:
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

Works and best solution IMHO.

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks,

  Hannes
