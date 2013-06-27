From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH] drivers: net: cpsw: add newline after MACID log
Date: Thu, 27 Jun 2013 15:21:53 +0530
Message-ID: <51CC0B39.6000404@ti.com>
References: <1372326047-28074-1-git-send-email-zonque@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>
To: Daniel Mack <zonque@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:38620 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750806Ab3F0JwP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jun 2013 05:52:15 -0400
In-Reply-To: <1372326047-28074-1-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/27/2013 3:10 PM, Daniel Mack wrote:
> Cosmetic patch to add a newline after logging the device's MACID.
>
> Signed-off-by: Daniel Mack <zonque@gmail.com>
> ---
>   drivers/net/ethernet/ti/cpsw.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index d1a769f..e10328d 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -1698,10 +1698,10 @@ static int cpsw_probe(struct platform_device *pdev)
>   
>   	if (is_valid_ether_addr(data->slave_data[0].mac_addr)) {
>   		memcpy(priv->mac_addr, data->slave_data[0].mac_addr, ETH_ALEN);
> -		pr_info("Detected MACID = %pM", priv->mac_addr);
> +		pr_info("Detected MACID = %pM\n", priv->mac_addr);
>   	} else {
>   		eth_random_addr(priv->mac_addr);
> -		pr_info("Random MACID = %pM", priv->mac_addr);
> +		pr_info("Random MACID = %pM\n", priv->mac_addr);
>   	}
>   
>   	memcpy(ndev->dev_addr, priv->mac_addr, ETH_ALEN);
Acked-by: Mugunthan V  N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
