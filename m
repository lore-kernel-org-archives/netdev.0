From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net 2/6] rtnetlink: bring NETDEV_CHANGE_TX_QUEUE_LEN event
 process back in rtnetlink_event
Date: Sun, 15 Oct 2017 19:16:09 -0600
Message-ID: <b20cbe6a-229e-58e1-b862-7d8b7a09dab2@gmail.com>
References: <cover.1508062280.git.lucien.xin@gmail.com>
 <d7713874f0ad1c19b640eaae98f0d554d1743a4c.1508062280.git.lucien.xin@gmail.com>
 <e240a6572c8e495eb2da15bd6178604cdfde08ba.1508062280.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, hannes@stressinduktion.org
To: Xin Long <lucien.xin@gmail.com>,
        network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:57009 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751410AbdJPBQL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Oct 2017 21:16:11 -0400
Received: by mail-pf0-f193.google.com with SMTP id b85so14559102pfj.13
        for <netdev@vger.kernel.org>; Sun, 15 Oct 2017 18:16:11 -0700 (PDT)
In-Reply-To: <e240a6572c8e495eb2da15bd6178604cdfde08ba.1508062280.git.lucien.xin@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/15/17 4:13 AM, Xin Long wrote:
> The same fix for changing mtu in the patch 'rtnetlink: bring
> NETDEV_CHANGEMTU event process back in rtnetlink_event' is
> needed for changing tx_queue_len.
> 
> Note that the redundant notifications issue for tx_queue_len
> will be fixed in the later patch 'rtnetlink: do not send
> notification for tx_queue_len in do_setlink'.
> 
> Fixes: 27b3b551d8a7 ("rtnetlink: Do not generate notifications for NETDEV_CHANGE_TX_QUEUE_LEN event")
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>  net/core/rtnetlink.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 72053ed..bf47360 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -4287,6 +4287,7 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
>  	case NETDEV_NOTIFY_PEERS:
>  	case NETDEV_RESEND_IGMP:
>  	case NETDEV_CHANGEINFODATA:
> +	case NETDEV_CHANGE_TX_QUEUE_LEN:
>  		rtmsg_ifinfo_event(RTM_NEWLINK, dev, 0, rtnl_get_event(event),
>  				   GFP_KERNEL);
>  		break;
> 

Acked-by: David Ahern <dsahern@gmail.com>
