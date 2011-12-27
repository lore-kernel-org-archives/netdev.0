From: Rob Herring <rob.herring@calxeda.com>
Subject: Re: [PATCH -next] net: calxeda xgmac ethernet driver add missing
 HAS_IOMEM dependency
Date: Tue, 27 Dec 2011 08:16:07 -0600
Message-ID: <4EF9D327.3070808@calxeda.com>
References: <1324994825-4197-1-git-send-email-heiko.carstens@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1324994825-4197-1-git-send-email-heiko.carstens@de.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/27/2011 08:07 AM, Heiko Carstens wrote:
> Fix allyesconfig build on architectures without IOMEM:
> 
> drivers/net/ethernet/calxeda/xgmac.c:1800:2:
>   error: implicit declaration of function 'iounmap' [-Werror=implicit-function-declaration]
> 
> Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: Rob Herring <rob.herring@calxeda.com>

Thanks.

Acked-by: Rob Herring <rob.herring@calxeda.com>

> ---
>  drivers/net/ethernet/calxeda/Kconfig |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ethernet/calxeda/Kconfig b/drivers/net/ethernet/calxeda/Kconfig
> index a52e725..aba435c 100644
> --- a/drivers/net/ethernet/calxeda/Kconfig
> +++ b/drivers/net/ethernet/calxeda/Kconfig
> @@ -1,6 +1,6 @@
>  config NET_CALXEDA_XGMAC
>  	tristate "Calxeda 1G/10G XGMAC Ethernet driver"
> -
> +	depends on HAS_IOMEM
>  	select CRC32
>  	help
>  	  This is the driver for the XGMAC Ethernet IP block found on Calxeda
