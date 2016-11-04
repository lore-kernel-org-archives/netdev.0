From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [net-next PATCH 0/7] stmmac: dwmac-sti refactor+cleanup
Date: Fri, 4 Nov 2016 14:49:31 +0100
Message-ID: <5eb811e8-0d1d-2e9e-245c-043a07c87bca@st.com>
References: <20161030200507.851-1-manabian@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <alexandre.torgue@st.com>, <netdev@vger.kernel.org>
To: Joachim Eastwood <manabian@gmail.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:55871 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933535AbcKDNti (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 09:49:38 -0400
In-Reply-To: <20161030200507.851-1-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Joachim.

I have tested the patches on STiH390 with GMAC4 and the driver is ok.

So you can add my Acked-by/Tested-by in the V2.

I just ask you, when rename the sti_dwmac_init in sti_dwmac_set_phy_mode
to use another name: sti_dwmac_set_mode could be good, IMO.

In fact, this function is not strictly related to the PHY and the
system config registers could touch different MAC/MII settings.

Regards
Peppe

On 10/30/2016 9:05 PM, Joachim Eastwood wrote:
> This patch set aims to remove the init/exit callbacks from the
> dwmac-sti driver and instead use standard PM callbacks. Doing this
> will also allow us to cleanup the driver.
>
> Eventually the init/exit callbacks will be deprecated and removed
> from all drivers dwmac-* except for dwmac-generic. Drivers will be
> refactored to use standard PM and remove callbacks.
>
> Note that this patch set has only been test compiled and no functional
> change is intended.
>
> Joachim Eastwood (7):
>   stmmac: dwmac-sti: remove useless of_node check
>   stmmac: dwmac-sti: remove clk NULL checks
>   stmmac: dwmac-sti: add PM ops and resume function
>   stmmac: dwmac-sti: move st,gmac_en parsing to sti_dwmac_parse_data
>   stmmac: dwmac-sti: move clk_prepare_enable out of init and add error handling
>   stmmac: dwmac-sti: clean up and rename sti_dwmac_init
>   stmmac: dwmac-sti: remove unused priv dev member
>
>  drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c | 86 ++++++++++++++++---------
>  1 file changed, 57 insertions(+), 29 deletions(-)
>
