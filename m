From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] stmmac: socfpga: Provide dt node to config ptp clk
 source.
Date: Sun, 06 Dec 2015 23:04:10 -0500 (EST)
Message-ID: <20151206.230410.527597426769762516.davem@davemloft.net>
References: <1449452324-53858-1-git-send-email-preid@electromag.com.au>
	<1449452324-53858-3-git-send-email-preid@electromag.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	peppe.cavallaro@st.com, devicetree@vger.kernel.org,
	netdev@vger.kernel.org
To: preid@electromag.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35075 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755373AbbLGEEM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Dec 2015 23:04:12 -0500
In-Reply-To: <1449452324-53858-3-git-send-email-preid@electromag.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Reid <preid@electromag.com.au>
Date: Mon,  7 Dec 2015 09:38:40 +0800

> @@ -116,6 +118,9 @@ static int socfpga_dwmac_parse_data(struct socfpga_dwmac *dwmac, struct device *
>  		return -EINVAL;
>  	}
>  
> +	dwmac->f2h_ptp_ref_clk = of_property_read_bool(np, "f2h_ptp_ref_clk");
> +
> +

Too many empty lines.

>  	np_splitter = of_parse_phandle(np, "altr,emac-splitter", 0);
>  	if (np_splitter) {
>  		if (of_address_to_resource(np_splitter, 0, &res_splitter)) {
> @@ -171,6 +176,11 @@ static int socfpga_dwmac_setup(struct socfpga_dwmac *dwmac)
>  	ctrl &= ~(SYSMGR_EMACGRP_CTRL_PHYSEL_MASK << reg_shift);
>  	ctrl |= val << reg_shift;
>  
> +	if(dwmac->f2h_ptp_ref_clk) 

Improperly formatted, there must be a space between the 'if' and the
openning parenthesis of the condition.
