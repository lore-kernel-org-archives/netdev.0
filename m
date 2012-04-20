From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 3/4] stmmac: verify the dma_cfg platform fields
Date: Thu, 19 Apr 2012 20:09:20 -0400 (EDT)
Message-ID: <20120419.200920.574162353846148225.davem@davemloft.net>
References: <1334814502-29707-1-git-send-email-peppe.cavallaro@st.com>
	<1334814502-29707-3-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, viresh.kumar@st.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55379 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753919Ab2DTAJZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 20:09:25 -0400
In-Reply-To: <1334814502-29707-3-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Thu, 19 Apr 2012 07:48:21 +0200

> Recently the dma parameters that can be passed from the platform
> have been moved from the plat_stmmacenet_data to the stmmac_dma_cfg.
> 
> In case of this new structure is not well allocated the driver can
> fails. This is an example how this field is managed in ST platforms
> 
> static struct stmmac_dma_cfg gmac_dma_setting = {
>         .pbl = 32,
> };
> 
> static struct plat_stmmacenet_data stih415_ethernet_platform_data[] = {
> 	{
> 		.dma_cfg = &gmac_dma_setting,
> 		.has_gmac = 1,
> [snip]
> 
> This patch so verifies that the dma_cfg passed from the platform.
> In case of it is NULL there is no reason that the driver has to fail
> and some default values can be passed. These are ok for all the
> Synopsys chips and could impact on performances, only.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> cc: Viresh Kumar <viresh.kumar@st.com>

Applied.
