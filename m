From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next] sunvnet: fix NULL pointer dereference
Date: Wed, 12 Nov 2014 11:12:37 -0500
Message-ID: <20141112161237.GB17946@oracle.com>
References: <546383B7.2090106@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David L Stevens <david.stevens@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:44590 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752377AbaKLQMq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 11:12:46 -0500
Content-Disposition: inline
In-Reply-To: <546383B7.2090106@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (11/12/14 10:58), David L Stevens wrote:
> --- a/drivers/net/ethernet/sun/sunvnet.c
> +++ b/drivers/net/ethernet/sun/sunvnet.c
> @@ -958,6 +958,8 @@ vnet_select_queue(struct net_device *dev, struct sk_buff *skb,
>  	struct vnet *vp = netdev_priv(dev);
>  	struct vnet_port *port = __tx_port_find(vp, skb);
>  
> +	if (port == NULL)
> +		return 0;
>  	return port->q_index;
>  }

Acked-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>

Thanks!
Sowmini
