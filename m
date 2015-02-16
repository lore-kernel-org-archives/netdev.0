From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 2/9] be2net: replace (1 << x) with BIT(x)
Date: Mon, 16 Feb 2015 15:09:24 +0300
Message-ID: <54E1DDF4.5040901@cogentembedded.com>
References: <1423228723-10919-1-git-send-email-sathya.perla@emulex.com> <1423228723-10919-3-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Sathya Perla <sathya.perla@emulex.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:64089 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751108AbbBPMJ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2015 07:09:28 -0500
Received: by mail-lb0-f182.google.com with SMTP id f15so25782311lbj.13
        for <netdev@vger.kernel.org>; Mon, 16 Feb 2015 04:09:26 -0800 (PST)
In-Reply-To: <1423228723-10919-3-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 2/6/2015 4:18 PM, Sathya Perla wrote:

> From: Vasundhara Volam <vasundhara.volam@emulex.com>

> BIT(x) is the preffered usage.

    Preferred.

> Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>

> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
[...]

> diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
> index 3b1d59d..9869556 100644
> --- a/drivers/net/ethernet/emulex/benet/be.h
> +++ b/drivers/net/ethernet/emulex/benet/be.h
> @@ -361,15 +361,15 @@ enum vf_state {
>   	ASSIGNED = 1
>   };
>
> -#define BE_FLAGS_LINK_STATUS_INIT		1
> -#define BE_FLAGS_SRIOV_ENABLED			(1 << 2)
> -#define BE_FLAGS_WORKER_SCHEDULED		(1 << 3)
> -#define BE_FLAGS_VLAN_PROMISC			(1 << 4)
> -#define BE_FLAGS_MCAST_PROMISC			(1 << 5)
> -#define BE_FLAGS_NAPI_ENABLED			(1 << 9)
> -#define BE_FLAGS_QNQ_ASYNC_EVT_RCVD		(1 << 11)
> -#define BE_FLAGS_VXLAN_OFFLOADS			(1 << 12)
> -#define BE_FLAGS_SETUP_DONE			(1 << 13)
> +#define BE_FLAGS_LINK_STATUS_INIT		BIT(1)

    Not BIT(0)?

> +#define BE_FLAGS_SRIOV_ENABLED			BIT(2)
> +#define BE_FLAGS_WORKER_SCHEDULED		BIT(3)
> +#define BE_FLAGS_VLAN_PROMISC			BIT(4)
> +#define BE_FLAGS_MCAST_PROMISC			BIT(5)
> +#define BE_FLAGS_NAPI_ENABLED			BIT(6)
> +#define BE_FLAGS_QNQ_ASYNC_EVT_RCVD		BIT(7)
> +#define BE_FLAGS_VXLAN_OFFLOADS			BIT(8)
> +#define BE_FLAGS_SETUP_DONE			BIT(9)

    So, you decided to renumber the bits?

[...]

WBR, Sergei
