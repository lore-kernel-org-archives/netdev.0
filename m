From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/5] sit: Add gro callbacks to sit offload
Date: Mon, 08 Sep 2014 04:55:30 -0700
Message-ID: <1410177330.11872.99.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1410153989-23837-1-git-send-email-therbert@google.com>
	 <1410153989-23837-4-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:41454 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752640AbaIHLzc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 07:55:32 -0400
Received: by mail-pa0-f41.google.com with SMTP id bj1so1663738pad.28
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2014 04:55:32 -0700 (PDT)
In-Reply-To: <1410153989-23837-4-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-09-07 at 22:26 -0700, Tom Herbert wrote:
> Add ip6_gro_receive and inet_gro_complete to ip6_offload to
> support GRO.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  net/ipv6/ip6_offload.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
> index 5bcda33..12a686f 100644
> --- a/net/ipv6/ip6_offload.c
> +++ b/net/ipv6/ip6_offload.c
> @@ -314,6 +314,8 @@ static const struct net_offload sit_offload = {
>  	.callbacks = {
>  		.gso_send_check = ipv6_gso_send_check,
>  		.gso_segment	= ipv6_gso_segment,
> +		.gro_receive	= ipv6_gro_receive,
> +		.gro_complete	= ipv6_gro_complete,
>  	},
>  };
>  

changelog has typos : It should be :

Add ip6_gro_receive and ip6_gro_complete to sit_offload to
support GRO.
