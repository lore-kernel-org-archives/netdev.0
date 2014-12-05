From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 3/3] rocker: set feature NETIF_F_HW_SWITCH_OFFLOAD
Date: Fri, 05 Dec 2014 16:18:26 +0300
Message-ID: <5481B0A2.9070109@cogentembedded.com>
References: <1417746401-8140-4-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com
To: roopa@cumulusnetworks.com, jiri@resnulli.us, sfeldma@gmail.com,
	jhs@mojatatu.com, bcrl@kvack.org, tgraf@suug.ch,
	john.fastabend@gmail.com, stephen@networkplumber.org,
	linville@tuxdriver.com, nhorman@tuxdriver.com,
	nicolas.dichtel@6wind.com, vyasevic@redhat.com,
	f.fainelli@gmail.com, buytenh@wantstofly.org, aviadr@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:39189 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748AbaLENSb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 08:18:31 -0500
Received: by mail-lb0-f176.google.com with SMTP id p9so525775lbv.35
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 05:18:29 -0800 (PST)
In-Reply-To: <1417746401-8140-4-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/5/2014 5:26 AM, roopa@cumulusnetworks.com wrote:

> From: Roopa Prabhu <roopa@cumulusnetworks.com>

> This patch just sets the feature flag on rocker ports

    You didn't sign off on any of your patches, hence they can't be applied.

> ---
>   drivers/net/ethernet/rocker/rocker.c |    3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
> index fded127..3fe19b0 100644
> --- a/drivers/net/ethernet/rocker/rocker.c
> +++ b/drivers/net/ethernet/rocker/rocker.c
> @@ -4003,7 +4003,8 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
>   		       NAPI_POLL_WEIGHT);
>   	rocker_carrier_init(rocker_port);
>
> -	dev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
> +	dev->features |= NETIF_F_HW_VLAN_CTAG_FILTER |
> +					 NETIF_F_HW_SWITCH_OFFLOAD;

    There was no need tho break the line.

[...]

WBR, Sergei
