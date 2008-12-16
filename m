From: Benjamin Thery <benjamin.thery@bull.net>
Subject: Re: [PATCH] igmp: allow IPPROTO_IGMP sockets in netns
Date: Tue, 16 Dec 2008 16:45:13 +0100
Message-ID: <4947CD09.6060605@bull.net>
References: <20080908012919.GD575@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:38738 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756037AbYLPPpY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 10:45:24 -0500
In-Reply-To: <20080908012919.GD575@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I was wondering what happened to this patch to support igmp socket 
per-netns sent by Alexey in September?

It looks like it has never been merged in net-next-2.6?

There's also this other patch sent at the same time by Alexey to make 
igmp proc entries per-netns that was "lost":

http://thread.gmane.org/gmane.linux.network/105226

Thanks,
Benjamin



Alexey Dobriyan wrote:
> Looks like everything is already ready.
> 
> Required for ebtables(8) for one thing.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> ---
> 
>  net/ipv4/af_inet.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -1310,6 +1310,7 @@ EXPORT_SYMBOL_GPL(snmp_mib_free);
>  #ifdef CONFIG_IP_MULTICAST
>  static struct net_protocol igmp_protocol = {
>  	.handler =	igmp_rcv,
> +	.netns_ok =	1,
>  };
>  #endif
>  
> 
> _______________________________________________
> Containers mailing list
> Containers@lists.linux-foundation.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
> 
> 


-- 
B e n j a m i n   T h e r y  - BULL/DT/Open Software R&D

    http://www.bull.com
