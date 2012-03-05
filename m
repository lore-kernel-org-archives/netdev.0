From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/6] stmmac: Add support for CPU freq notifiers.
Date: Sun, 04 Mar 2012 20:50:45 -0500 (EST)
Message-ID: <20120304.205045.1678554604028231988.davem@davemloft.net>
References: <1330692928-30330-2-git-send-email-deepak.sikri@st.com>
	<1330692928-30330-3-git-send-email-deepak.sikri@st.com>
	<1330692928-30330-4-git-send-email-deepak.sikri@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, spear-devel@list.st.com,
	netdev@vger.kernel.org
To: deepak.sikri@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47603 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755314Ab2CEBuy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2012 20:50:54 -0500
In-Reply-To: <1330692928-30330-4-git-send-email-deepak.sikri@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Deepak Sikri <deepak.sikri@st.com>
Date: Fri, 2 Mar 2012 18:25:25 +0530

> +{
> +
> +	if ((clk_rate >= CSR_F_20M) && (clk_rate < CSR_F_35M))
 ...
> +		priv->plat->clk_csr = STMMAC_CLK_RANGE_150_250M;
> +
> +}

Unnecessary empty lines, remove them.

> +			/*
> +			 * Decide on the MDC clock dynamically based on the
> +			 * csr clock input.

Format comments:

	/* Like
	 * this.
	 */

Not:

	/*
	 * Like
	 * this.
	 */

> +static inline void stmmac_cpufreq_deregister(struct stmmac_priv *priv)
> +{
> +
> +	cpufreq_unregister_notifier(&priv->freq_transition,

Unnecessary empty line.
