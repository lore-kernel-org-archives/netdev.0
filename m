From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2 5/5] stmmac: socfpga: Provide dt node to config ptp clk source.
Date: Mon, 07 Dec 2015 10:05:07 +0100
Message-ID: <2600741.aLNrbYNOOu@wuerfel>
References: <1449452324-53858-1-git-send-email-preid@electromag.com.au> <1449452324-53858-7-git-send-email-preid@electromag.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	peppe.cavallaro@st.com, davem@davemloft.net,
	devicetree@vger.kernel.org, netdev@vger.kernel.org
To: Phil Reid <preid@electromag.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.10]:60926 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754969AbbLGJFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 04:05:41 -0500
In-Reply-To: <1449452324-53858-7-git-send-email-preid@electromag.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 07 December 2015 09:38:44 Phil Reid wrote:
> Signed-off-by: Phil Reid <preid@electromag.com.au>
> ---
>  Documentation/devicetree/bindings/net/socfpga-dwmac.txt | 2 ++
>  drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c     | 9 +++++++++
>  2 files changed, 11 insertions(+)
> 
> diff --git a/Documentation/devicetree/bindings/net/socfpga-dwmac.txt b/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
> index 3a9d679..72d82d6 100644
> --- a/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
> +++ b/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
> @@ -11,6 +11,8 @@ Required properties:
>                   designware version numbers documented in stmmac.txt
>   - altr,sysmgr-syscon : Should be the phandle to the system manager node that
>     encompasses the glue register, the register offset, and the register shift.
> + - altr,f2h_ptp_ref_clk use f2h_ptp_ref_clk instead of default eosc1 clock
> +   for ptp ref clk. This affects all emacs as the clock is common.
> 

Is this feature specific to the Altera glue logic, or would it be possible
to do the same thing on another dwmac implementation?

	Arnd
