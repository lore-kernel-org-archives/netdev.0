From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/8] net: stmicro: configure tx queue weight
Date: Wed, 08 Mar 2017 11:16:43 -0800 (PST)
Message-ID: <20170308.111643.2131946337725707531.davem@davemloft.net>
References: <cover.1488969672.git.jpinto@synopsys.com>
        <cover.1488969672.git.jpinto@synopsys.com>
        <934aafa1865c51601a95054ffa9b4ffaeb32df79.1488969672.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org
To: Joao.Pinto@synopsys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52956 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752094AbdCHTYe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 14:24:34 -0500
In-Reply-To: <934aafa1865c51601a95054ffa9b4ffaeb32df79.1488969672.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joao Pinto <Joao.Pinto@synopsys.com>
Date: Wed,  8 Mar 2017 11:03:10 +0000

> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index af57f8d..df3b1ee 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -1645,6 +1645,23 @@ static void stmmac_init_tx_coalesce(struct stmmac_priv *priv)
>  }
>  
>  /**
> + *  stmmac_set_tx_queue_weight - Set TX queue weight
> + *  @priv: driver private structure
> + *  Description: It is used for setting TX queues weight
> + */
> +static void stmmac_set_tx_queue_weight(struct stmmac_priv *priv)
> +{
> +	u32 tx_queues_count = priv->plat->tx_queues_to_use;
> +	u32 queue = 0;
> +	u32 weight = 0;

Please order local variable declarations from longest to shortest
line.
