From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: ethernet: stmmac: add ARP management
Date: Tue, 17 Jan 2017 09:17:38 -0800
Message-ID: <bfb14469-25a0-7a65-3203-d49820412edf@gmail.com>
References: <1484672200-7755-1-git-send-email-christophe.roullier@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Christophe Roullier <christophe.roullier@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34474 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750888AbdAQRTa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 12:19:30 -0500
In-Reply-To: <1484672200-7755-1-git-send-email-christophe.roullier@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/17/2017 08:56 AM, Christophe Roullier wrote:
> DWC_ether_qos supports the Address Recognition
> Protocol (ARP) Offload for IPv4 packets. This feature
> allows the processing of the IPv4 ARP request packet
> in the receive path and generating corresponding ARP
> response packet in the transmit path. DWC_ether_qos
> generates the ARP reply packets for appropriate ARP
> request packets.


> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> index 4daa8a3..92a0db9 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> @@ -306,6 +306,7 @@ struct plat_stmmacenet_data *
>  		plat->has_gmac = 0;
>  		plat->pmt = 1;
>  		plat->tso_en = of_property_read_bool(np, "snps,tso");
> +		plat->arp_en = of_property_read_bool(np, "snps,arp");

You introduce a new property that needs to be documented in the Device
Tree binding document for stmmac.
-- 
Florian
