From: Jie Deng <Jie.Deng1@synopsys.com>
Subject: Re: [PATCH 1/2] [net-next] net: dwc-xlgmac: include dcbnl.h
Date: Tue, 21 Mar 2017 10:22:15 +0800
Message-ID: <0d31b33a-d682-f6d5-7bdc-1cce7f20e52f@synopsys.com>
References: <20170320085123.1032301-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>, Jie Deng <Jie.Deng1@synopsys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170320085123.1032301-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2017/3/20 16:51, Arnd Bergmann wrote:
> Without this header, we can run into a build error:
>
> drivers/net/ethernet/synopsys/dwc-xlgmac-hw.c: In function 'xlgmac_config_queue_mapping':
> drivers/net/ethernet/synopsys/dwc-xlgmac-hw.c:1548:36: error: 'IEEE_8021QAZ_MAX_TCS' undeclared (first use in this function)
>   prio_queues = min_t(unsigned int, IEEE_8021QAZ_MAX_TCS,
>
> Fixes: 65e0ace2c5cd ("net: dwc-xlgmac: Initial driver for DesignWare Enterprise Ethernet")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  drivers/net/ethernet/synopsys/dwc-xlgmac-hw.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/drivers/net/ethernet/synopsys/dwc-xlgmac-hw.c b/drivers/net/ethernet/synopsys/dwc-xlgmac-hw.c
> index 5cf3e90d4834..1e25a86f6a27 100644
> --- a/drivers/net/ethernet/synopsys/dwc-xlgmac-hw.c
> +++ b/drivers/net/ethernet/synopsys/dwc-xlgmac-hw.c
> @@ -22,6 +22,7 @@
>  #include <linux/clk.h>
>  #include <linux/bitrev.h>
>  #include <linux/crc32.h>
> +#include <linux/dcbnl.h>
>  
>  #include "dwc-xlgmac.h"
>  #include "dwc-xlgmac-reg.h"
Thanks.
Reviewed-by: Jie Deng <jiedeng@synopsys.com>
