From: Varka Bhadram <varkabhadram@gmail.com>
Subject: Re: [net-next 01/10] net: Rename ndo_add_vxlan_port to ndo_add_udp_tunnel_port.
Date: Tue, 22 Jul 2014 16:19:25 +0530
Message-ID: <53CE41B5.5070608@gmail.com>
References: <1406024393-6778-1-git-send-email-azhou@nicira.com> <1406024393-6778-2-git-send-email-azhou@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andy Zhou <azhou@nicira.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:60712 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753826AbaGVKun (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 06:50:43 -0400
Received: by mail-pa0-f49.google.com with SMTP id hz1so11597034pad.8
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 03:50:42 -0700 (PDT)
In-Reply-To: <1406024393-6778-2-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/22/2014 03:49 PM, Andy Zhou wrote:

(...)

>   
> -/* Calls the ndo_add_vxlan_port of the caller in order to
> +/* Calls the ndo_add_tunnel_port of the caller in order to
>    * supply the listening VXLAN udp ports. Callers are expected
> - * to implement the ndo_add_vxlan_port.
> + * to implement the ndo_add_tunnle_port.
>    */
>   void vxlan_get_rx_port(struct net_device *dev)
>   {
> @@ -2206,8 +2209,8 @@ void vxlan_get_rx_port(struct net_device *dev)
>   		hlist_for_each_entry_rcu(vs, &vn->sock_list[i], hlist) {
>   			port = inet_sk(vs->sock->sk)->inet_sport;
>   			sa_family = vs->sock->sk->sk_family;
> -			dev->netdev_ops->ndo_add_vxlan_port(dev, sa_family,
> -							    port);
> +			dev->netdev_ops->ndo_add_udp_tunnel_port(dev,
> +					sa_family, port, UDP_TUNNEL_TYPE_VXLAN);

Should match open parenthesis:
	dev->netdev_ops->ndo_add_udp_tunnel_port(dev,
						 sa_family, port,
						 UDP_TUNNEL_TYPE_VXLAN);

>   


-- 
Regards,
Varka Bhadram.
