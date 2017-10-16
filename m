From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net 4/6] rtnetlink: bring NETDEV_CHANGEUPPER event process
 back in rtnetlink_event
Date: Sun, 15 Oct 2017 19:16:23 -0600
Message-ID: <b7981160-03f2-5343-a476-fc2e625741a1@gmail.com>
References: <cover.1508062280.git.lucien.xin@gmail.com>
 <d7713874f0ad1c19b640eaae98f0d554d1743a4c.1508062280.git.lucien.xin@gmail.com>
 <e240a6572c8e495eb2da15bd6178604cdfde08ba.1508062280.git.lucien.xin@gmail.com>
 <b4125c6cf42d4d028a9c04f4989627ac1eb83257.1508062280.git.lucien.xin@gmail.com>
 <784f477a1f9e8b9a5ec7bbe9e1dff1dcdfd5553b.1508062280.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, hannes@stressinduktion.org
To: Xin Long <lucien.xin@gmail.com>,
        network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:55166 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751657AbdJPBQZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Oct 2017 21:16:25 -0400
Received: by mail-pg0-f67.google.com with SMTP id l24so5451666pgu.11
        for <netdev@vger.kernel.org>; Sun, 15 Oct 2017 18:16:25 -0700 (PDT)
In-Reply-To: <784f477a1f9e8b9a5ec7bbe9e1dff1dcdfd5553b.1508062280.git.lucien.xin@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/15/17 4:13 AM, Xin Long wrote:
> libteam needs this event notification in userspace when dev's master
> dev has been changed. After this, the redundant notifications issue
> would be fixed in the later patch 'rtnetlink: check DO_SETLINK_NOTIFY
> correctly in do_setlink'.
> 
> Fixes: b6b36eb23a46 ("rtnetlink: Do not generate notifications for NETDEV_CHANGEUPPER event")
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>  net/core/rtnetlink.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 8e44fd5..ab98c1c 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -4286,6 +4286,7 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
>  	case NETDEV_BONDING_FAILOVER:
>  	case NETDEV_POST_TYPE_CHANGE:
>  	case NETDEV_NOTIFY_PEERS:
> +	case NETDEV_CHANGEUPPER:
>  	case NETDEV_RESEND_IGMP:
>  	case NETDEV_CHANGEINFODATA:
>  	case NETDEV_CHANGE_TX_QUEUE_LEN:
> 

Acked-by: David Ahern <dsahern@gmail.com>
