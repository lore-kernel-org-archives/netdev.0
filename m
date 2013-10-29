From: David Daney <ddaney.cavm@gmail.com>
Subject: Re: [PATCH] netdev: octeon_mgmt: drop redundant mac address check
Date: Tue, 29 Oct 2013 09:33:56 -0700
Message-ID: <526FE374.2050304@gmail.com>
References: <1383010061-25461-1-git-send-email-luka@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, david.daney@cavium.com
To: Luka Perkov <luka@openwrt.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:60790 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751243Ab3J2Qd7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 12:33:59 -0400
Received: by mail-ie0-f175.google.com with SMTP id aq17so180390iec.6
        for <netdev@vger.kernel.org>; Tue, 29 Oct 2013 09:33:58 -0700 (PDT)
In-Reply-To: <1383010061-25461-1-git-send-email-luka@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/28/2013 06:27 PM, Luka Perkov wrote:
> Checking if MAC address is valid using is_valid_ether_addr() is already done in
> of_get_mac_address().
>
> Signed-off-by: Luka Perkov <luka@openwrt.org>

This looks sane, but I haven't tested it...

Acked-by: David Daney <david.daney@cavium.com>


> ---
>   drivers/net/ethernet/octeon/octeon_mgmt.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/octeon/octeon_mgmt.c b/drivers/net/ethernet/octeon/octeon_mgmt.c
> index 622aa75..1b326cbc 100644
> --- a/drivers/net/ethernet/octeon/octeon_mgmt.c
> +++ b/drivers/net/ethernet/octeon/octeon_mgmt.c
> @@ -1545,7 +1545,7 @@ static int octeon_mgmt_probe(struct platform_device *pdev)
>
>   	mac = of_get_mac_address(pdev->dev.of_node);
>
> -	if (mac && is_valid_ether_addr(mac))
> +	if (mac)
>   		memcpy(netdev->dev_addr, mac, ETH_ALEN);
>   	else
>   		eth_hw_addr_random(netdev);
>
