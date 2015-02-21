From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] ethtool: Add hw-switch-offload to netdev_features_strings.
Date: Sat, 21 Feb 2015 20:31:37 +0300
Message-ID: <54E8C0F9.9070508@cogentembedded.com>
References: <1424472648-24828-1-git-send-email-ramirose@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: Rami Rosen <ramirose@gmail.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:42392 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751005AbbBURbm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Feb 2015 12:31:42 -0500
Received: by lbiw7 with SMTP id w7so11778257lbi.9
        for <netdev@vger.kernel.org>; Sat, 21 Feb 2015 09:31:40 -0800 (PST)
In-Reply-To: <1424472648-24828-1-git-send-email-ramirose@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 2/21/2015 1:50 AM, Rami Rosen wrote:

> commit aafb3e98b279 (netdev: introduce new NETIF_F_HW_SWITCH_OFFLOAD feature
> flag for switch device offloads) added a new feature without adding it to
> netdev_features_strings array; this patch fixes this.

> Signed-off-by: Rami Rosen <ramirose@gmail.com>
> ---
>   net/core/ethtool.c | 1 +
>   1 file changed, 1 insertion(+)

> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index 91f74f3..fc5feda 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -98,6 +98,7 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
>   	[NETIF_F_RXALL_BIT] =            "rx-all",
>   	[NETIF_F_HW_L2FW_DOFFLOAD_BIT] = "l2-fwd-offload",
>   	[NETIF_F_BUSY_POLL_BIT] =        "busy-poll",
> +        [NETIF_F_HW_SWITCH_OFFLOAD_BIT] = "hw-switch-offload",

    Please use tab for the indentation.

[...]

WBR, Sergei
