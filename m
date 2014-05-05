From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH v2 0/6] Add CPTS support for AM437x
Date: Mon, 5 May 2014 19:52:24 +0530
Message-ID: <53679EA0.3050606@ti.com>
References: <1399012324-20737-1-git-send-email-george.cherian@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <richardcochran@gmail.com>,
	<jeffrey.t.kirsher@intel.com>, <dborkman@redhat.com>,
	<ast@plumgrid.com>, <tklauser@distanz.ch>, <mpa@pengutronix.de>,
	<bhutchings@solarflare.com>, <zonque@gmail.com>, <balbi@ti.com>,
	<t-kristo@ti.com>, <mturquette@linaro.org>,
	<linux@arm.linux.org.uk>, <galak@codeaurora.org>,
	<ijc+devicetree@hellion.org.uk>, <mark.rutland@arm.com>,
	<pawel.moll@arm.com>, <robh+dt@kernel.org>, <tony@atomide.com>,
	<bcousson@baylibre.com>
To: George Cherian <george.cherian@ti.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<devicetree@vger.kernel.org>, <linux-omap@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:40155 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932636AbaEEOXk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 May 2014 10:23:40 -0400
In-Reply-To: <1399012324-20737-1-git-send-email-george.cherian@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 02 May 2014 12:01 PM, George Cherian wrote:
> The series adds CPTS support for AM4372.
>
> Patch 1 - DT changes w.r.t clock changes for AM33xx.
> Patch 2 - CPTS clock name harcoding in the driver is removed. 
> 	  Easier to pass the clock name from dt rather than hardcoding in driver.
> 	  Also in prepration for DRA7x CPTS support.
> Patch 3 - Enable the CPTS support for both DRA7x and AM4372 in the driver.
> Patch 4 - Enable the Annexe F for L2 PTP for AM437x and DRA7x.
> Patch 5 - Change the default clocksource to dpll_core_m5 
> Patch 6 - DT changes for AM4372.
>
>
> v1 -> v2
> 	Patch 1 and 2 Re-ordering.
> 	Seperate TS_BITS define for Hw version V2 and V3
>
> George Cherian (6):
>   ARM: dts: am33xx: Add clock names for cpsw and cpts
>   drivers: net: cpts: Remove hardcoded clock name for CPTS
>   drivers: net: cpsw: Enable CPTS for DRA7xx and AM4372
>   drivers: net: cpsw: Enable Annexe F Time sync
>   ARM: AM43xx: clk: Change the cpts ref clock source to dpll_core_m5 clk
>   ARM: dts: am4372: Add clock names for cpsw and cpts
>
>  arch/arm/boot/dts/am33xx.dtsi  |  2 ++
>  arch/arm/boot/dts/am4372.dtsi  |  2 ++
>  drivers/clk/ti/clk-43xx.c      | 16 ++++++++++++
>  drivers/net/ethernet/ti/cpsw.c | 56 +++++++++++++++++++++++++++++++-----------
>  drivers/net/ethernet/ti/cpts.c | 11 +++------
>  5 files changed, 66 insertions(+), 21 deletions(-)
>

Acked-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
