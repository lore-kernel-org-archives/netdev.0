From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v5] IPv6: add the option to use anycast addresses as source addresses in echo reply
Date: Tue, 7 Jan 2014 21:51:01 +0100
Message-ID: <20140107205101.GJ30393@order.stressinduktion.org>
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
Received: from order.stressinduktion.org ([87.106.68.36]:46253 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752610AbaAGUvC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 15:51:02 -0500
Content-Disposition: inline
In-Reply-To: <1389103047-3380-1-git-send-email-fx.lebail@yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 07, 2014 at 02:57:27PM +0100, Francois-Xavier Le Bail wrote:
> --- a/include/net/netns/ipv6.h
> +++ b/include/net/netns/ipv6.h
> @@ -73,6 +73,7 @@ struct netns_ipv6 {
>  #endif
>  	atomic_t		dev_addr_genid;
>  	atomic_t		rt_genid;
> +	int			anycast_src_echo_reply;
>  };
>  

Sorry, I missed that on first review and you could also do that as a
follow-up:

Could you move anycast_src_echo_reply to netns_sysctl_ipv6?

Thanks,

  Hannes
