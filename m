From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [PATCH][v2] netdev/phy: mdio-mux-mmioreg.c should include of_address.h
Date: Fri, 07 Sep 2012 16:42:26 -0700
Message-ID: <504A8662.9050907@xenotime.net>
References: <1347053457-24935-1-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, sfr@canb.auug.org.au
To: Timur Tabi <timur@freescale.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1347053457-24935-1-git-send-email-timur@freescale.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/07/2012 02:30 PM, Timur Tabi wrote:

> mdio-mux-mmioreg.c uses function of_address_to_resource(), which is defined
> in linux/of_address.h.  This fixes a compilation error:
> 
> drivers/net/phy/mdio-mux-mmioreg.c: In function 'mdio_mux_mmioreg_probe':
> drivers/net/phy/mdio-mux-mmioreg.c:83:2: error: implicit declaration of
> 	function 'of_address_to_resource'
> 
> Reported-by: Randy Dunlap <rdunlap@xenotime.net>
> Signed-off-by: Timur Tabi <timur@freescale.com>
> 


Acked-by: Randy Dunlap <rdunlap@xenotime.net>

Thanks.

> ---
>  drivers/net/phy/mdio-mux-mmioreg.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/phy/mdio-mux-mmioreg.c b/drivers/net/phy/mdio-mux-mmioreg.c
> index 098239a..9061ba6 100644
> --- a/drivers/net/phy/mdio-mux-mmioreg.c
> +++ b/drivers/net/phy/mdio-mux-mmioreg.c
> @@ -12,6 +12,7 @@
>  
>  #include <linux/platform_device.h>
>  #include <linux/device.h>
> +#include <linux/of_address.h>
>  #include <linux/of_mdio.h>
>  #include <linux/module.h>
>  #include <linux/init.h>



-- 
~Randy
