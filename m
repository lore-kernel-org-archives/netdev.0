From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] net: Fix typo in netdev_intersect_features
Date: Mon, 11 Jan 2016 21:24:41 +0300
Message-ID: <5693F369.6020600@cogentembedded.com>
References: <1452536350-432426-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jackm@dev.mellanox.co.il, kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:33059 "EHLO
	mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759629AbcAKSYp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 13:24:45 -0500
Received: by mail-lf0-f43.google.com with SMTP id m198so71821703lfm.0
        for <netdev@vger.kernel.org>; Mon, 11 Jan 2016 10:24:44 -0800 (PST)
In-Reply-To: <1452536350-432426-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 01/11/2016 09:19 PM, Tom Herbert wrote:

> Obviously need to 'or in NETIF_F_IP_CSUM and NETIF_F_IPV6_CSUM.
>
> Fixes: c8cd0989bd151f ("net: Eliminate NETIF_F_GEN_CSUM and NETIF_F_V[46]_CSUM")
> Reported-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
> Signed-off-by: Tom Herbert <tom@herbertland.com>
> ---
>   include/linux/netdevice.h | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 8d8e5ca..a951274 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -3871,9 +3871,9 @@ static inline netdev_features_t netdev_intersect_features(netdev_features_t f1,
>   {
>   	if ((f1 ^ f2) & NETIF_F_HW_CSUM) {
>   		if (f1 & NETIF_F_HW_CSUM)
> -			f1 |= (NETIF_F_IP_CSUM|NETIF_F_IP_CSUM);
> +			f1 |= (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM);
>   		else
> -			f2 |= (NETIF_F_IP_CSUM|NETIF_F_IP_CSUM);
> +			f2 |= (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM);

    The general kernel coding style is to have the operators surrounded by spaces.

[...]

WBR, Sergei
