From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 3/3] stmmac: pci: Use dmi_system_id table for retrieving
 PHY addresses
Date: Mon, 22 May 2017 04:33:50 -0700
Message-ID: <1495452830.2093.14.camel@perches.com>
References: <cover.1495451529.git.jan.kiszka@siemens.com>
         <c8e6966227a9c2981e822b2deac8c036651b088c.1495451529.git.jan.kiszka@siemens.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Andy Shevchenko <andy.shevchenko@gmail.com>
To: Jan Kiszka <jan.kiszka@siemens.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0162.hostedemail.com ([216.40.44.162]:44656 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S932406AbdEVLdz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 07:33:55 -0400
In-Reply-To: <c8e6966227a9c2981e822b2deac8c036651b088c.1495451529.git.jan.kiszka@siemens.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-05-22 at 13:12 +0200, Jan Kiszka wrote:
> Avoids reimplementation of DMI matching in stmmac_pci_find_phy_addr.
[]
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
[]
> @@ -31,65 +31,78 @@
[]
> +static const struct stmmac_pci_dmi_data iot2040_stmmac_dmi_data[] = {
>  	{
> -		.name = "GalileoGen2",
>  		.func = 6,
>  		.phy_addr = 1,
>  	},
>  	{
> -		.name = "SIMATIC IOT2000",
> -		.asset_tag = "6ES7647-0AA00-0YA2",
> -		.func = 6,
> +		.func = 7,

Why change this from 6 to 7?
