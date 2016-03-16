From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [net-next 1/2] bonding: remove duplicate set of flag
 IFF_MULTICAST
Date: Wed, 16 Mar 2016 10:01:09 -0400
Message-ID: <20160316140108.GO572@gospo.home.greyhouse.net>
References: <1458122356-25021-1-git-send-email-zhangshengju@cmss.chinamobile.com>
 <1458122356-25021-2-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, j.vosburgh@gmail.com, jiri@resnulli.us,
	netdev@vger.kernel.org
To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:32921 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966568AbcCPOBP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 10:01:15 -0400
Received: by mail-qg0-f54.google.com with SMTP id a36so11790811qge.0
        for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 07:01:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1458122356-25021-2-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 16, 2016 at 09:59:15AM +0000, Zhang Shengju wrote:
> Remove unnecessary set of flag IFF_MULTICAST, since ether_setup
> already does this.
> 
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>

> ---
>  drivers/net/bonding/bond_main.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index b6236ff..270b39c 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -4175,7 +4175,7 @@ void bond_setup(struct net_device *bond_dev)
>  	SET_NETDEV_DEVTYPE(bond_dev, &bond_type);
>  
>  	/* Initialize the device options */
> -	bond_dev->flags |= IFF_MASTER|IFF_MULTICAST;
> +	bond_dev->flags |= IFF_MASTER;
>  	bond_dev->priv_flags |= IFF_BONDING | IFF_UNICAST_FLT | IFF_NO_QUEUE;
>  	bond_dev->priv_flags &= ~(IFF_XMIT_DST_RELEASE | IFF_TX_SKB_SHARING);
>  
> -- 
> 1.8.3.1
> 
> 
> 
