From: Paul Walmsley <paul@pwsan.com>
Subject: Re: [PATCH 3/4] OMAP3 : clock data: Update name string for EMAC
 clocks.
Date: Thu, 11 Mar 2010 19:02:24 -0700 (MST)
Message-ID: <alpine.DEB.2.00.1003111901300.23781@utopia.booyaka.com>
References: <1268320422-32656-1-git-send-email-srk@ti.com> <1268320422-32656-2-git-send-email-srk@ti.com> <1268320422-32656-3-git-send-email-srk@ti.com> <1268320422-32656-4-git-send-email-srk@ti.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-omap@vger.kernel.org, netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com
To: Sriramakrishnan <srk@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1268320422-32656-4-git-send-email-srk@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 11 Mar 2010, Sriramakrishnan wrote:

> The emac driver uses generic name for the module and phy
> clocks. Updated the omap3xxx_clks table to match the names
> used by the Davinci emac driver.
> 
> Signed-off-by: Sriramakrishnan <srk@ti.com>

Acked-by: Paul Walmsley <paul@pwsan.com>

At some point, someone should go through that davinci_emac.c driver and 
change the DaVinci references to "TI" or something generic, now that this 
core exists on DaVinci, OMAP, etc.

> ---
>  arch/arm/mach-omap2/clock3xxx_data.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/arm/mach-omap2/clock3xxx_data.c b/arch/arm/mach-omap2/clock3xxx_data.c
> index d5153b6..989da2e 100644
> --- a/arch/arm/mach-omap2/clock3xxx_data.c
> +++ b/arch/arm/mach-omap2/clock3xxx_data.c
> @@ -3472,8 +3472,8 @@ static struct omap_clk omap3xxx_clks[] = {
>  	CLK(NULL,	"ipss_ick",	&ipss_ick,	CK_AM35XX),
>  	CLK(NULL,	"rmii_ck",	&rmii_ck,	CK_AM35XX),
>  	CLK(NULL,	"pclk_ck",	&pclk_ck,	CK_AM35XX),
> -	CLK("davinci_emac",	"ick",		&emac_ick,	CK_AM35XX),
> -	CLK("davinci_emac",	"fck",		&emac_fck,	CK_AM35XX),
> +	CLK("davinci_emac",	"emac_clk",	&emac_ick,	CK_AM35XX),
> +	CLK("davinci_emac",	"phy_clk",	&emac_fck,	CK_AM35XX),
>  	CLK("vpfe-capture",	"master",	&vpfe_ick,	CK_AM35XX),
>  	CLK("vpfe-capture",	"slave",	&vpfe_fck,	CK_AM35XX),
>  	CLK("musb_hdrc",	"ick",		&hsotgusb_ick_am35xx,	CK_AM35XX),
> -- 
> 1.6.2.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-omap" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


- Paul
