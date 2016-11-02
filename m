From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [net-next PATCH 0/7] stmmac: dwmac-sti refactor+cleanup
Date: Wed, 2 Nov 2016 07:39:32 +0100
Message-ID: <f5f43786-92ea-fcc7-388c-9b87a47987f9@st.com>
References: <20161030200507.851-1-manabian@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <alexandre.torgue@st.com>, <netdev@vger.kernel.org>
To: Joachim Eastwood <manabian@gmail.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:34102 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750786AbcKBGjj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 02:39:39 -0400
In-Reply-To: <20161030200507.851-1-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Joachim

thx for this series, I will review them and test the changes
on my board asap ... I let you known.

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
