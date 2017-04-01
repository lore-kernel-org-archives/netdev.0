From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/2] rtnetlink: Convert rtnetlink_event to white
 list
Date: Sat, 1 Apr 2017 09:51:56 -0600
Message-ID: <299c6c86-9a35-f3b6-2658-caad0e6f825f@cumulusnetworks.com>
References: <1491013654-395-1-git-send-email-vyasevic@redhat.com>
 <1491013654-395-2-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
        Vladislav Yasevich <vyasevic@redhat.com>
To: Vladislav Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:36089 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750820AbdDAQHX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Apr 2017 12:07:23 -0400
Received: by mail-pg0-f44.google.com with SMTP id g2so90169524pge.3
        for <netdev@vger.kernel.org>; Sat, 01 Apr 2017 09:07:23 -0700 (PDT)
In-Reply-To: <1491013654-395-2-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/31/17 8:27 PM, Vladislav Yasevich wrote:
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 9c3947a..f48a60d 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -4116,22 +4116,23 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
>  	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
>  
>  	switch (event) {
> -	case NETDEV_UP:
> -	case NETDEV_DOWN:
> -	case NETDEV_PRE_UP:
> -	case NETDEV_POST_INIT:
> -	case NETDEV_REGISTER:
> -	case NETDEV_CHANGE:
> -	case NETDEV_PRE_TYPE_CHANGE:
> -	case NETDEV_GOING_DOWN:
> -	case NETDEV_UNREGISTER:
> -	case NETDEV_UNREGISTER_FINAL:
> -	case NETDEV_RELEASE:
> -	case NETDEV_JOIN:
> -	case NETDEV_BONDING_INFO:
> +	case NETDEV_REBOOT:
> +	case NETDEV_CHANGEMTU:
> +	case NETDEV_CHANGENAME:
> +	case NETDEV_FEAT_CHANGE:
> +	case NETDEV_BONDING_FAILOVER:
> +	case NETDEV_NOTIFY_PEERS:
> +	case NETDEV_CHANGEUPPER:
> +	case NETDEV_RESEND_IGMP:
> +	case NETDEV_PRECHANGEMTU:
> +	case NETDEV_CHANGEINFODATA:
> +	case NETDEV_PRECHANGEUPPER:
> +	case NETDEV_CHANGELOWERSTATE:
> +	case NETDEV_UDP_TUNNEL_PUSH_INFO:
> +	case NETDEV_CHANGE_TX_QUEUE_LEN:

missing NETDEV_CHANGEADDR and NETDEV_POST_TYPE_CHANGE

since this patch is just flipping the list type, those should be added here.
