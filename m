From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next] ipvlan: read direct ifindex instead of iflink
Date: Wed, 21 Oct 2015 13:26:10 +0200
Message-ID: <20151021132611.436eafe6@griffin>
References: <20151020234732.GA16302@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, maheshb@google.com
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50021 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753806AbbJUL0P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Oct 2015 07:26:15 -0400
In-Reply-To: <20151020234732.GA16302@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 20 Oct 2015 16:47:33 -0700, Brenden Blanco wrote:
> --- a/drivers/net/ipvlan/ipvlan_core.c
> +++ b/drivers/net/ipvlan/ipvlan_core.c
> @@ -348,7 +348,7 @@ static int ipvlan_process_v4_outbound(struct sk_buff *skb)
>  	struct rtable *rt;
>  	int err, ret = NET_XMIT_DROP;
>  	struct flowi4 fl4 = {
> -		.flowi4_oif = dev_get_iflink(dev),
> +		.flowi4_oif = dev->ifindex,

The current code is obviously wrong and the patch makes sense.

Reviewed-by: Jiri Benc <jbenc@redhat.com>

-- 
Jiri Benc
