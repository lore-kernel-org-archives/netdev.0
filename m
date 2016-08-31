From: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@c0d3.blue>
Subject: Re: [Bridge] [PATCH net-next v2 2/2] net: bridge: add per-port
 multicast flood flag
Date: Wed, 31 Aug 2016 03:37:26 +0200
Message-ID: <20160831013726.GD4883@otheros>
References: <1472570588-32503-1-git-send-email-nikolay@cumulusnetworks.com>
 <1472570588-32503-3-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        bridge@lists.linux-foundation.org, davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.aperture-lab.de ([138.201.29.205]:59537 "EHLO
        mail.aperture-lab.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754140AbcHaBhs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 21:37:48 -0400
Content-Disposition: inline
In-Reply-To: <1472570588-32503-3-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 30, 2016 at 05:23:08PM +0200, Nikolay Aleksandrov via Bridge wrote:
> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
> index 1da3221845f1..ed0dd3340084 100644
> --- a/net/bridge/br_if.c
> +++ b/net/bridge/br_if.c
> @@ -362,7 +362,7 @@ static struct net_bridge_port *new_nbp(struct net_bridge *br,
>  	p->path_cost = port_cost(dev);
>  	p->priority = 0x8000 >> BR_PORT_BITS;
>  	p->port_no = index;
> -	p->flags = BR_LEARNING | BR_FLOOD;
> +	p->flags = BR_LEARNING | BR_FLOOD | BR_MCAST_FLOOD;

I'm discontent with this new flag becoming the default.

Could you elaborate a little more on your use-case, when/why do
you want/need this flag?
