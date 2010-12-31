From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 02/15]drivers:spi:dw_spi.c Typo change diable to disable.
Date: Thu, 30 Dec 2010 23:45:15 -0700
Message-ID: <20101231064515.GC3733@angua.secretlab.ca>
References: <1293750484-1161-1-git-send-email-justinmattock@gmail.com>
	<1293750484-1161-2-git-send-email-justinmattock@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, trivial@kernel.org, linux-scsi@vger.kernel.org,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	ivtv-devel@ivtvdriver.org, linux-m68k@lists.linux-m68k.org,
	spi-devel-general@lists.sourceforge.net, linux-media@vger.kernel.org
To: "Justin P. Mattock" <justinmattock@gmail.com>
Return-path: <devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <1293750484-1161-2-git-send-email-justinmattock@gmail.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
	<mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Sender: devel-bounces@linuxdriverproject.org
Errors-To: devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 30, 2010 at 03:07:51PM -0800, Justin P. Mattock wrote:
> The below patch fixes a typo "diable" to "disable". Please let me know if this 
> is correct or not.
> 
> Signed-off-by: Justin P. Mattock <justinmattock@gmail.com>

applied, thanks.

g.

> 
> ---
>  drivers/spi/dw_spi.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/spi/dw_spi.c b/drivers/spi/dw_spi.c
> index 0838c79..7c3cf21 100644
> --- a/drivers/spi/dw_spi.c
> +++ b/drivers/spi/dw_spi.c
> @@ -592,7 +592,7 @@ static void pump_transfers(unsigned long data)
>  		spi_set_clk(dws, clk_div ? clk_div : chip->clk_div);
>  		spi_chip_sel(dws, spi->chip_select);
>  
> -		/* Set the interrupt mask, for poll mode just diable all int */
> +		/* Set the interrupt mask, for poll mode just disable all int */
>  		spi_mask_intr(dws, 0xff);
>  		if (imask)
>  			spi_umask_intr(dws, imask);
> -- 
> 1.6.5.2.180.gc5b3e
> 
> 
> ------------------------------------------------------------------------------
> Learn how Oracle Real Application Clusters (RAC) One Node allows customers
> to consolidate database storage, standardize their database environment, and, 
> should the need arise, upgrade to a full multi-node Oracle RAC database 
> without downtime or disruption
> http://p.sf.net/sfu/oracle-sfdevnl
> _______________________________________________
> spi-devel-general mailing list
> spi-devel-general@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/spi-devel-general
