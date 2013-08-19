From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2] vhost: Include linux/uio.h instead of linux/socket.h
Date: Mon, 19 Aug 2013 10:24:08 +0300
Message-ID: <20130819072408.GC17937@redhat.com>
References: <20130816.222946.421410239742571372.davem@davemloft.net>
	<1376875399-21945-1-git-send-email-asias@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Asias He <asias@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1376875399-21945-1-git-send-email-asias@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 19, 2013 at 09:23:19AM +0800, Asias He wrote:
> memcpy_fromiovec is moved from net/core/iovec.c to lib/iovec.c.
> linux/uio.h provides the declaration for memcpy_fromiovec.
> 
> Include linux/uio.h instead of inux/socket.h for it.
> 
> Signed-off-by: Asias He <asias@redhat.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
>  drivers/vhost/vhost.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index e58cf00..448efe0 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -13,7 +13,7 @@
>  
>  #include <linux/eventfd.h>
>  #include <linux/vhost.h>
> -#include <linux/socket.h> /* memcpy_fromiovec */
> +#include <linux/uio.h>
>  #include <linux/mm.h>
>  #include <linux/mmu_context.h>
>  #include <linux/miscdevice.h>
> -- 
> 1.8.3.1
