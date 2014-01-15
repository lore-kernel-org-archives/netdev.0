From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 3/3] ipv6: add ip6_flowlabel_consistency sysctl
Date: Wed, 15 Jan 2014 01:59:49 +0100
Message-ID: <20140115005948.GA19945@order.stressinduktion.org>
References: <1389721816-21165-1-git-send-email-florent.fourcot@enst-bretagne.fr> <1389721816-21165-3-git-send-email-florent.fourcot@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:37667 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918AbaAOA7u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 19:59:50 -0500
Content-Disposition: inline
In-Reply-To: <1389721816-21165-3-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 14, 2014 at 06:50:16PM +0100, Florent Fourcot wrote:
> diff --git a/kernel/sysctl_binary.c b/kernel/sysctl_binary.c
> index 653cbbd..7c32501 100644
> --- a/kernel/sysctl_binary.c
> +++ b/kernel/sysctl_binary.c
> @@ -557,6 +557,7 @@ static const struct bin_table bin_net_ipv6_table[] = {
>  	{ CTL_DIR,	NET_IPV6_ROUTE,		"route",	bin_net_ipv6_route_table },
>  	{ CTL_DIR,	NET_IPV6_ICMP,		"icmp",		bin_net_ipv6_icmp_table },
>  	{ CTL_INT,	NET_IPV6_BINDV6ONLY,		"bindv6only" },
> +	{ CTL_INT,	NET_IPV6_FLOWLABEL_CONSISTENCY,	"ip6_flowlabel_consistency" },
>  	{ CTL_INT,	NET_IPV6_IP6FRAG_HIGH_THRESH,	"ip6frag_high_thresh" },
>  	{ CTL_INT,	NET_IPV6_IP6FRAG_LOW_THRESH,	"ip6frag_low_thresh" },
>  	{ CTL_INT,	NET_IPV6_IP6FRAG_TIME,		"ip6frag_time" },

This hunk is not necessary and should get removed. bin_tables are legacy. Also
I didn't see NET_IPV6_FLOWLABEL_CONSISTENCY getting defined. ;)

Greetings,

  Hannes
