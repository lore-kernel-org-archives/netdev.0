From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net v3 2/3] libphy: Add stubs to hook IEEE MMD Register
 reads and writes
Date: Mon, 23 Jun 2014 16:29:10 +0400
Message-ID: <53A81D96.3040904@cogentembedded.com>
References: <1403482910-20821-1-git-send-email-vbridgers2013@gmail.com> <1403482910-20821-3-git-send-email-vbridgers2013@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Vince Bridgers <vbridgers2013@gmail.com>, f.fainelli@gmail.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:34877 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751432AbaFWM3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 08:29:12 -0400
Received: by mail-lb0-f179.google.com with SMTP id z11so4429020lbi.10
        for <netdev@vger.kernel.org>; Mon, 23 Jun 2014 05:29:11 -0700 (PDT)
In-Reply-To: <1403482910-20821-3-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06/23/2014 04:21 AM, Vince Bridgers wrote:

> The Micrel ksz9021 PHY does not support standard IEEE standard MMD
> extended register access, therefore requires stubs to fail the read
> register method and do nothing for the write register method when
> libphy attempts to read and/or configure Energy Efficient Ethernet
> features in PHYS that do support those features. This problem
> was observed on an Altera Cyclone V SOC development kit that
> uses the Synopsys EMAC and the Micrel ksz9021 PHY. This patch
> was tested on the same board, and Energy Efficient Ethernet is
> now disabled as expected since the Micrel PHY does not support that
> feature.

> Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
> ---
> V3: Remove unnecessary returns from void functions.
> V2: Split libphy and Micrel specific changes into 2 patches
>      based on review comments
> ---
>   drivers/net/phy/micrel.c |   23 ++++++++++++++++++++++-
>   1 file changed, 22 insertions(+), 1 deletion(-)

> diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
> index bc7c7d2..daf8bab 100644
> --- a/drivers/net/phy/micrel.c
> +++ b/drivers/net/phy/micrel.c
> @@ -417,7 +417,26 @@ static int ksz8873mll_read_status(struct phy_device *phydev)
>
>   static int ksz8873mll_config_aneg(struct phy_device *phydev)
>   {
> -	return 0;

    Eh? The function returns *int* and you're removing the only *return* 
statement?

> +}

WBR, Sergei
