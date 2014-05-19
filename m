From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 1/4] net: bcmgenet: use the new fixed PHY helpers
Date: Tue, 20 May 2014 01:22:16 +0400
Message-ID: <537A7608.4000906@cogentembedded.com>
References: <1400528625-32744-1-git-send-email-f.fainelli@gmail.com> <1400528625-32744-2-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, thomas.petazzoni@free-electrons.com,
	devicetree@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:60043 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752539AbaESVWR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2014 17:22:17 -0400
Received: by mail-lb0-f174.google.com with SMTP id n15so4556331lbi.33
        for <netdev@vger.kernel.org>; Mon, 19 May 2014 14:22:16 -0700 (PDT)
In-Reply-To: <1400528625-32744-2-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 05/19/2014 11:43 PM, Florian Fainelli wrote:

> of_phy_connect_fixed_link() is becoming obsolete, and also required
> platform code to register the fixed PHYs at the specified addresses for
> those to be usable. Get rid of it and use the new of_phy_is_fixed_link()
> plus of_phy_register_fixed_link() helpers to transition over the new
> scheme.

> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>   drivers/net/ethernet/broadcom/genet/bcmmii.c | 22 ++++++++++++++--------
>   1 file changed, 14 insertions(+), 8 deletions(-)

> diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
> index 4608673beaff..69bc69f86638 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
> +++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
[...]
> @@ -307,15 +308,20 @@ static int bcmgenet_mii_probe(struct net_device *dev)
[...]
> +	phydev = of_phy_connect(dev, priv->phy_dn, bcmgenet_mii_setup, 0,
> +					priv->phy_interface);

    The continuation line is indented incorrectly, you should have started it 
right under 'dev' on the previous line.

WBR, Sergei
