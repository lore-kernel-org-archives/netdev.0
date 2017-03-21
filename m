From: Jie Deng <Jie.Deng1@synopsys.com>
Subject: Re: [PATCH 2/2] [net-next] net: dwc-xlgmac: add module license
Date: Tue, 21 Mar 2017 10:34:05 +0800
Message-ID: <c146aa97-3c33-e457-7a1d-435a6efeaeaf@synopsys.com>
References: <20170320085123.1032301-1-arnd@arndb.de>
 <20170320085123.1032301-2-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>, Jie Deng <Jie.Deng1@synopsys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170320085123.1032301-2-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2017/3/20 16:51, Arnd Bergmann wrote:
> When building the driver as a module, we get a warning about the
> lack of a license:
>
> WARNING: modpost: missing MODULE_LICENSE() in drivers/net/ethernet/synopsys/dwc-xlgmac.o
> see include/linux/module.h for more information
>
> Curiously the text in the .c files only mentions GPLv2+, while the license
> tag in the PCI driver contains both GPL and BSD. I picked the license text
> as the more definite reference here and put a GPL tag in there.
>
> Fixes: 65e0ace2c5cd ("net: dwc-xlgmac: Initial driver for DesignWare Enterprise Ethernet")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  drivers/net/ethernet/synopsys/dwc-xlgmac-common.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/drivers/net/ethernet/synopsys/dwc-xlgmac-common.c b/drivers/net/ethernet/synopsys/dwc-xlgmac-common.c
> index 726d78ac4907..b72196ab647f 100644
> --- a/drivers/net/ethernet/synopsys/dwc-xlgmac-common.c
> +++ b/drivers/net/ethernet/synopsys/dwc-xlgmac-common.c
> @@ -25,6 +25,7 @@
>  
>  static int debug = -1;
>  module_param(debug, int, 0644);
> +MODULE_LICENSE("GPL");
>  MODULE_PARM_DESC(debug, "DWC ethernet debug level (0=none,...,16=all)");
>  static const u32 default_msg_level = (NETIF_MSG_LINK | NETIF_MSG_IFDOWN |
>  				      NETIF_MSG_IFUP);
This driver uses dual license. I will update the headers to include BSD. Thanks!
