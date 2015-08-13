From: Tony Lindgren <tony@atomide.com>
Subject: Re: [net-next PATCH 2/3] ARM: dts: dra7: update cpsw compatible
Date: Thu, 13 Aug 2015 02:55:36 -0700
Message-ID: <20150813095536.GB4215@atomide.com>
References: <1439373175-8650-1-git-send-email-mugunthanvnm@ti.com>
 <1439373175-8650-3-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-omap@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>, alex.aring@gmail.com
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from muru.com ([72.249.23.125]:44107 "EHLO muru.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752247AbbHMJzl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Aug 2015 05:55:41 -0400
Content-Disposition: inline
In-Reply-To: <1439373175-8650-3-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Mugunthan V N <mugunthanvnm@ti.com> [150812 02:56]:
> CPSW driver has been updated with compatibles for enabling errata
> workarounds. So updating cpsw compatibles.
> 
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>

Please feel free to merge this one via net tree once the changes
are reviewed:

Acked-by: Tony Lindgren <tony@atomide.com>

> ---
>  arch/arm/boot/dts/dra7.dtsi | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/arch/arm/boot/dts/dra7.dtsi b/arch/arm/boot/dts/dra7.dtsi
> index 8f1e25b..b4fdd10 100644
> --- a/arch/arm/boot/dts/dra7.dtsi
> +++ b/arch/arm/boot/dts/dra7.dtsi
> @@ -1398,7 +1398,7 @@
>  		};
>  
>  		mac: ethernet@4a100000 {
> -			compatible = "ti,cpsw";
> +			compatible = "ti,dra7-cpsw","ti,cpsw";
>  			ti,hwmods = "gmac";
>  			clocks = <&dpll_gmac_ck>, <&gmac_gmii_ref_clk_div>;
>  			clock-names = "fck", "cpts";
> -- 
> 2.5.0.234.gefc8a62
> 
