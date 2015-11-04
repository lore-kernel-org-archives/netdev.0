From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [patch net-next] net: add forgotten IFF_L3MDEV_SLAVE define
Date: Wed, 4 Nov 2015 07:43:53 -0700
Message-ID: <563A19A9.3040508@cumulusnetworks.com>
References: <1446645546-588-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:36672 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932178AbbKDOn4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2015 09:43:56 -0500
Received: by pacdm15 with SMTP id dm15so30726033pac.3
        for <netdev@vger.kernel.org>; Wed, 04 Nov 2015 06:43:56 -0800 (PST)
In-Reply-To: <1446645546-588-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/4/15 6:59 AM, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> Fixes: fee6d4c77 ("net: Add netif_is_l3_slave")
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>   include/linux/netdevice.h | 1 +
>   1 file changed, 1 insertion(+)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 4ac653b..2c00772 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1322,6 +1322,7 @@ enum netdev_priv_flags {
>   #define IFF_L3MDEV_MASTER		IFF_L3MDEV_MASTER
>   #define IFF_NO_QUEUE			IFF_NO_QUEUE
>   #define IFF_OPENVSWITCH			IFF_OPENVSWITCH
> +#define IFF_L3MDEV_SLAVE		IFF_L3MDEV_SLAVE
>
>   /**
>    *	struct net_device - The DEVICE structure.
>

Acked-by: David Ahern <dsa@cumulusnetworks.com>

Thanks, Jiri.
