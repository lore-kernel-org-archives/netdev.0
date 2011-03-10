From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH 1/8] macb: unify at91 and avr32 platform data
Date: Thu, 10 Mar 2011 14:06:04 +0100
Message-ID: <4D78CCBC.2010807@atmel.com>
References: <1299751843-9743-1-git-send-email-jamie@jamieiles.com>
	<1299751843-9743-2-git-send-email-jamie@jamieiles.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Jamie Iles <jamie@jamieiles.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1299751843-9743-2-git-send-email-jamie@jamieiles.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 3/10/2011 11:10 AM, Jamie Iles :
> --- a/drivers/net/macb.c
> +++ b/drivers/net/macb.c
> @@ -18,12 +18,10 @@
>  #include <linux/netdevice.h>
>  #include <linux/etherdevice.h>
>  #include <linux/dma-mapping.h>
> +#include <linux/platform_data/macb.h>
>  #include <linux/platform_device.h>
>  #include <linux/phy.h>
>  
> -#include <mach/board.h>
> -#include <mach/cpu.h>

I did not bouble check but do we need no more cpu_is_ macros?

> -
>  #include "macb.h"
>  
>  #define RX_BUFFER_SIZE		128

-- 
Nicolas Ferre
