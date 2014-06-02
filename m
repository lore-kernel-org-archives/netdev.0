From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: stmmac: Handle different error codes
 from platform_get_irq_byname
Date: Mon, 02 Jun 2014 14:05:20 -0700 (PDT)
Message-ID: <20140602.140520.1193655810822953539.davem@davemloft.net>
References: <1401373900-30253-1-git-send-email-wens@csie.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	grygorii.strashko@ti.com, linux@arm.linux.org.uk, robh@kernel.org,
	maxime.ripard@free-electrons.com
To: wens@csie.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36796 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752465AbaFBVFU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 17:05:20 -0400
In-Reply-To: <1401373900-30253-1-git-send-email-wens@csie.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chen-Yu Tsai <wens@csie.org>
Date: Thu, 29 May 2014 22:31:40 +0800

> The following patch moved device tree interrupt resolution into
> platform_get_irq_byname:
> 
>   ad69674 of/irq: do irq resolution in platform_get_irq_byname()
> 
> As a result, the function no longer only return -ENXIO on error.
> This breaks DT based probing of stmmac, as seen in test runs of
> linux-next next-20140526 cubie2-sunxi_defconfig:
> 
>   http://lists.linaro.org/pipermail/kernel-build-reports/2014-May/003659.html
> 
> This patch makes the stmmac_platform probe function properly handle
> error codes, such as returning for deferred probing, and other codes
> returned by of_irq_get_by_name.
> 
> Signed-off-by: Chen-Yu Tsai <wens@csie.org>

Applied, thanks.
