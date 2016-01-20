From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] sfc: Replace memset with eth_zero_addr
Date: Wed, 20 Jan 2016 14:44:08 +0300
Message-ID: <569F7308.9060008@cogentembedded.com>
References: <1453246074-1054-1-git-send-email-tanure@linux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Lucas Tanure <tanure@linux.com>,
	Shradha Shah <sshah@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:36339 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751751AbcATLoL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 06:44:11 -0500
Received: by mail-lb0-f172.google.com with SMTP id oh2so3512905lbb.3
        for <netdev@vger.kernel.org>; Wed, 20 Jan 2016 03:44:10 -0800 (PST)
In-Reply-To: <1453246074-1054-1-git-send-email-tanure@linux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 1/20/2016 2:27 AM, Lucas Tanure wrote:

> Use eth_zero_addr to assign the zero address to the given address array
> instead of memset when second argument is address of zero.

    What address? memset() takes just 1 address. :-)

> Signed-off-by: Lucas Tanure <tanure@linux.com>
> ---
>   drivers/net/ethernet/sfc/ef10_sriov.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/sfc/ef10_sriov.c b/drivers/net/ethernet/sfc/ef10_sriov.c
> index 3c17f27..10f60db 100644
> --- a/drivers/net/ethernet/sfc/ef10_sriov.c
> +++ b/drivers/net/ethernet/sfc/ef10_sriov.c
> @@ -527,7 +527,7 @@ int efx_ef10_sriov_set_vf_mac(struct efx_nic *efx, int vf_i, u8 *mac)
>   	return 0;
>
>   fail:
> -	memset(vf->mac, 0, ETH_ALEN);
> +	eth_zero_addr(vf->mac);
>   	return rc;
>   }
>

MBR, Sergei
