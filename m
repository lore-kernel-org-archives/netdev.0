From: Asias He <asias@redhat.com>
Subject: Re: [PATCH] vhost: drop virtio_net.h dependency
Date: Mon, 6 May 2013 21:23:29 +0800
Message-ID: <20130506132329.GB12160@hj.localdomain>
References: <20130506103734.GA12481@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Christian Borntraeger <borntraeger@de.ibm.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20130506103734.GA12481@redhat.com>
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

On Mon, May 06, 2013 at 01:37:34PM +0300, Michael S. Tsirkin wrote:
> There's no net specific code in vhost.c anymore,
> don't include the virtio_net.h header.

Did you push the it to your tree. I am not seeing it.

> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
> 
> This is on top of Asias' patches, already queued so
> just FYI.
> 
>  drivers/vhost/vhost.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index de9441a..dcde269 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -13,7 +13,6 @@
>  
>  #include <linux/eventfd.h>
>  #include <linux/vhost.h>
> -#include <linux/virtio_net.h>
>  #include <linux/mm.h>
>  #include <linux/mmu_context.h>
>  #include <linux/miscdevice.h>
> -- 
> MST

-- 
Asias
