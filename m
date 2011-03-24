From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH 4/4] can: c_can: remove duplicated #include
Date: Thu, 24 Mar 2011 17:15:50 +0100
Message-ID: <4D8B6E36.601@grandegger.com>
References: <1300457247-2652-1-git-send-email-weiyi.huang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Huang Weiyi <weiyi.huang-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1300457247-2652-1-git-send-email-weiyi.huang-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/18/2011 03:07 PM, Huang Weiyi wrote:
> Remove duplicated #include('s) in
>   drivers/net/can/c_can/c_can.c
>   drivers/net/can/c_can/c_can_platform.c
> 
> Signed-off-by: Huang Weiyi <weiyi.huang-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  drivers/net/can/c_can/c_can.c          |    1 -
>  drivers/net/can/c_can/c_can_platform.c |    1 -
>  2 files changed, 0 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
> index 1405078..b343bcb 100644
> --- a/drivers/net/can/c_can/c_can.c
> +++ b/drivers/net/can/c_can/c_can.c
> @@ -34,7 +34,6 @@
>  #include <linux/if_arp.h>
>  #include <linux/if_ether.h>
>  #include <linux/list.h>
> -#include <linux/delay.h>
>  #include <linux/io.h>
>  
>  #include <linux/can.h>
> diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c_can/c_can_platform.c
> index e629b96..61c41ba 100644
> --- a/drivers/net/can/c_can/c_can_platform.c
> +++ b/drivers/net/can/c_can/c_can_platform.c
> @@ -28,7 +28,6 @@
>  #include <linux/if_arp.h>
>  #include <linux/if_ether.h>
>  #include <linux/list.h>
> -#include <linux/delay.h>
>  #include <linux/io.h>
>  #include <linux/platform_device.h>
>  #include <linux/clk.h>

Acked-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>

I added a CC to the netdev mailing list. Hope that's sufficient to get
the patch accepted.

Thanks,

Wolfgang.
