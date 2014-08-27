From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net.git) 3/4] stmmac: never check EEE in case of a
 switch is attached
Date: Wed, 27 Aug 2014 16:28:08 -0700 (PDT)
Message-ID: <20140827.162808.1981938022641305719.davem@davemloft.net>
References: <1409037383-3213-1-git-send-email-peppe.cavallaro@st.com>
	<1409037383-3213-4-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41745 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964948AbaH0X2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 19:28:09 -0400
In-Reply-To: <1409037383-3213-4-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Date: Tue, 26 Aug 2014 09:16:22 +0200

> From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
> 
> This patch is to skip the EEE initialisation when the stmmac
> is using a switch (with a fixed phy support).
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 51a89d4..48a112f 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -276,6 +276,7 @@ static void stmmac_eee_ctrl_timer(unsigned long arg)
>  bool stmmac_eee_init(struct stmmac_priv *priv)
>  {
>  	bool ret = false;
> +	char *phy_bus_name = priv->plat->phy_bus_name;
>  
>  	/* Using PCS we cannot dial with the phy registers at this stage
>  	 * so we do not support extra feature like EEE.

Please order local variable declarations in reverse-christmas-tree order,
this means longer lines come before shorter ones.

Thanks.
