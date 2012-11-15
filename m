From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/3] ipip: fix sparse warnings in
 ipip_netlink_parms()
Date: Thu, 15 Nov 2012 05:15:50 -0800
Message-ID: <1352985350.4497.28.camel@edumazet-glaptop>
References: <1352969616-30476-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:62623 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1767743Ab2KONPy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 08:15:54 -0500
Received: by mail-ie0-f174.google.com with SMTP id k13so2118519iea.19
        for <netdev@vger.kernel.org>; Thu, 15 Nov 2012 05:15:54 -0800 (PST)
In-Reply-To: <1352969616-30476-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-11-15 at 09:53 +0100, Nicolas Dichtel wrote:
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>  net/ipv4/ipip.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
> index 64686e1..c26c171 100644
> --- a/net/ipv4/ipip.c
> +++ b/net/ipv4/ipip.c
> @@ -864,10 +864,10 @@ static void ipip_netlink_parms(struct nlattr *data[],
>  		parms->link = nla_get_u32(data[IFLA_IPTUN_LINK]);
>  
>  	if (data[IFLA_IPTUN_LOCAL])
> -		parms->iph.saddr = nla_get_u32(data[IFLA_IPTUN_LOCAL]);
> +		parms->iph.saddr = nla_get_be32(data[IFLA_IPTUN_LOCAL]);
>  
>  	if (data[IFLA_IPTUN_REMOTE])
> -		parms->iph.daddr = nla_get_u32(data[IFLA_IPTUN_REMOTE]);
> +		parms->iph.daddr = nla_get_be32(data[IFLA_IPTUN_REMOTE]);
>  
>  	if (data[IFLA_IPTUN_TTL]) {
>  		parms->iph.ttl = nla_get_u8(data[IFLA_IPTUN_TTL]);


No credit for who reported this bug ?
