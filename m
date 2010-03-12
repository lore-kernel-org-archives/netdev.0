From: Kevin Hilman <khilman@deeprootsystems.com>
Subject: Re: [PATCH 3/4] OMAP3 : clock data: Update name string for EMAC clocks.
Date: Fri, 12 Mar 2010 15:26:45 -0800
Message-ID: <8763515dfu.fsf@deeprootsystems.com>
References: <1268320422-32656-1-git-send-email-srk@ti.com>
	<1268320422-32656-2-git-send-email-srk@ti.com>
	<1268320422-32656-3-git-send-email-srk@ti.com>
	<1268320422-32656-4-git-send-email-srk@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-omap@vger.kernel.org, netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com
To: Sriramakrishnan <srk@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1268320422-32656-4-git-send-email-srk@ti.com> (Sriramakrishnan's message of "Thu\, 11 Mar 2010 20\:43\:41 +0530")
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sriramakrishnan <srk@ti.com> writes:

> The emac driver uses generic name for the module and phy
> clocks. Updated the omap3xxx_clks table to match the names
> used by the Davinci emac driver.
>
> Signed-off-by: Sriramakrishnan <srk@ti.com>
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

As I mentioned in the review of the equivalent davinci changes,
I'm not crazy abou the _clk suffixes on the con_id.  I think
these should be called "main" (or "emac") and "phy".

Kevin
