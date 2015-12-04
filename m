From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH 5/5] stmmac: socfpga: Provide dt node to config ptp clk
 source.
Date: Fri, 4 Dec 2015 10:19:49 -0600
Message-ID: <20151204161949.GA11372@rob-hp-laptop>
References: <1449220125-67417-1-git-send-email-preid@electromag.com.au>
 <1449220125-67417-6-git-send-email-preid@electromag.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	davem@davemloft.net
To: Phil Reid <preid@electromag.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:56552 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753840AbbLDQTx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Dec 2015 11:19:53 -0500
Content-Disposition: inline
In-Reply-To: <1449220125-67417-6-git-send-email-preid@electromag.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 04, 2015 at 05:08:45PM +0800, Phil Reid wrote:
> Signed-off-by: Phil Reid <preid@electromag.com.au>
> ---
>  Documentation/devicetree/bindings/net/socfpga-dwmac.txt |  2 ++
>  drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c     | 10 ++++++++++
>  2 files changed, 12 insertions(+)
> 
> diff --git a/Documentation/devicetree/bindings/net/socfpga-dwmac.txt b/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
> index 3a9d679..72d82d6 100644
> --- a/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
> +++ b/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
> @@ -11,6 +11,8 @@ Required properties:
>  		  designware version numbers documented in stmmac.txt
>   - altr,sysmgr-syscon : Should be the phandle to the system manager node that
>     encompasses the glue register, the register offset, and the register shift.
> + - altr,f2h_ptp_ref_clk use f2h_ptp_ref_clk instead of default eosc1 clock
> +   for ptp ref clk. This affects all emacs as the clock is common.

This and ...

> +	dwmac->f2h_ptp_ref_clk = of_property_read_bool(np, "f2h_ptp_ref_clk");

this don't match.
