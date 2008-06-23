From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 04/25] netns ct: point from conntrack to netns
Date: Mon, 23 Jun 2008 12:06:13 +0200
Message-ID: <485F7595.7030609@trash.net>
References: <20080622010239.GE5392@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	den@openvz.org, xemul@openvz.org, ebiederm@xmission.com,
	benjamin.thery@bull.net, dlezcano@fr.ibm.com
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43821 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754469AbYFWKGR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 06:06:17 -0400
In-Reply-To: <20080622010239.GE5392@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Dobriyan wrote:
> +static inline struct net *ct_net(const struct nf_conn *ct)
> +{
> +#ifdef CONFIG_NET_NS
> +	return ct->ct_net;
> +#else
> +	return &init_net;
> +#endif
> +}

For consistency I'd prefer nf_ct_net(). I know this naming scheme
isn't used consistenly currently, but we're moving towards it.
