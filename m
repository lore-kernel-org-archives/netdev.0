From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] Stmmac: fix a bug when clk_csr is euqal to 0x0
Date: Thu, 17 Oct 2013 15:39:15 -0400 (EDT)
Message-ID: <20131017.153915.2233536980001549266.davem@davemloft.net>
References: <CAKT61h9Cv=g5stPBnp25XiUyfPy_NxBKxtAABUHm+GajCHMGWA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peppe.cavallaro@st.com
To: mcuos.com@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46457 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762499Ab3JQTjT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 15:39:19 -0400
In-Reply-To: <CAKT61h9Cv=g5stPBnp25XiUyfPy_NxBKxtAABUHm+GajCHMGWA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wan ZongShun <mcuos.com@gmail.com>
Date: Sat, 12 Oct 2013 10:04:20 +0800

> According to spec, if csr clock freq is 60-100Mhz, we have to set CR[5:2] = 0000
> but when I set the 'plat_dat.clk_csr = 0',acctually, this value is not used
> since the driver code judge 'if (!priv->plat->clk_csr)' then go to dynamic tune
> the MDC clock. So this patch is to add other judge condition.
> 
> Signed-off-by: Wan Zongshun <mcuos.com@gmail.com>

There are still many problems with this patch.

Do not capitalize "Stmmac" in the subject prefix, use plain "stmmac: "

There is a typo in "equal" in the subject line.

> @@ -148,6 +149,8 @@ Where:
>         GMAC also enables the 4xPBL by default.
>     o fixed_burst/mixed_burst/burst_len
>   o clk_csr: fixed CSR Clock range selection.
> + o dynamic_mdc_clk_en: If it is set to >=1 MDC clk will be selected
> dynamically,
> +               or else you must set a fixed CSR Clock range to clk_src.
>   o has_gmac: uses the GMAC core.
>   o enh_desc: if sets the MAC will use the enhanced descriptor structure.
>   o tx_coe: core is able to perform the tx csum in HW.

The patch has been corrupted by your email client.
