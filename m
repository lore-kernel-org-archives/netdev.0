From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [patch net-next v2 01/12] fib: notifier: Add VIF add and delete
 event types
Date: Mon, 25 Sep 2017 12:20:54 +0300
Message-ID: <01cc3964-6968-df38-a3ea-376a26677243@cumulusnetworks.com>
References: <20170924172212.10096-1-jiri@resnulli.us>
 <20170924172212.10096-2-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, andrew@lunn.ch
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:49870 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933236AbdIYJU6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 05:20:58 -0400
Received: by mail-wm0-f49.google.com with SMTP id r74so17440041wme.4
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 02:20:58 -0700 (PDT)
In-Reply-To: <20170924172212.10096-2-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/09/17 20:22, Jiri Pirko wrote:
> From: Yotam Gigi <yotamg@mellanox.com>
> 
> In order for an interface to forward packets according to the kernel
> multicast routing table, it must be configured with a VIF index according
> to the mroute user API. The VIF index is then used to refer to that
> interface in the mroute user API, for example, to set the iif and oifs of
> an MFC entry.
> 
> In order to allow drivers to be aware and offload multicast routes, they
> have to be aware of the VIF add and delete notifications.
> 
> Due to the fact that a specific VIF can be deleted and re-added pointing to
> another netdevice, and the MFC routes that point to it will forward the
> matching packets to the new netdevice, a driver willing to offload MFC
> cache entries must be aware of the VIF add and delete events in addition to
> MFC routes notifications.
> 
> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  include/net/fib_notifier.h | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/include/net/fib_notifier.h b/include/net/fib_notifier.h
> index 669b971..54cd6b8 100644
> --- a/include/net/fib_notifier.h
> +++ b/include/net/fib_notifier.h
> @@ -20,6 +20,8 @@ enum fib_event_type {
>  	FIB_EVENT_RULE_DEL,
>  	FIB_EVENT_NH_ADD,
>  	FIB_EVENT_NH_DEL,
> +	FIB_EVENT_VIF_ADD,
> +	FIB_EVENT_VIF_DEL,
>  };
>  
>  struct fib_notifier_ops {
> 

Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
