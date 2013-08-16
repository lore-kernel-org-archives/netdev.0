From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 1/2] net-next: sundance: Add netconsole logging
 support
Date: Sat, 17 Aug 2013 03:46:49 +0400
Message-ID: <520EB9E9.2020200@cogentembedded.com>
References: <1376672417-2798-1-git-send-email-kda@linux-powerpc.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Denis Kirjanov <kda@linux-powerpc.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:50124 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757252Ab3HQAQR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Aug 2013 20:16:17 -0400
Received: by mail-la0-f42.google.com with SMTP id ep20so2015788lab.29
        for <netdev@vger.kernel.org>; Fri, 16 Aug 2013 17:16:16 -0700 (PDT)
In-Reply-To: <1376672417-2798-1-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 08/16/2013 09:00 PM, Denis Kirjanov wrote:

    I'd rather name the patch "sundance: add netpoll support". "net-next:" 
shouldn't be there twice definitely.

> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
> ---
>   drivers/net/ethernet/dlink/sundance.c | 14 ++++++++++++++
>   1 file changed, 14 insertions(+)

> diff --git a/drivers/net/ethernet/dlink/sundance.c b/drivers/net/ethernet/dlink/sundance.c
> index 50d9c63..2688a84 100644
> --- a/drivers/net/ethernet/dlink/sundance.c
> +++ b/drivers/net/ethernet/dlink/sundance.c
[...]
> @@ -480,6 +491,9 @@ static const struct net_device_ops netdev_ops = {
>   	.ndo_change_mtu		= change_mtu,
>   	.ndo_set_mac_address 	= sundance_set_mac_addr,
>   	.ndo_validate_addr	= eth_validate_addr,
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +	.ndo_poll_controller = sundance_poll_controller,

    Could you align = here with the reset of initializers?

> +#endif

WBR, Sergei
