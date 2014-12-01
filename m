From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next] vhost: remove unnecessary forward declarations
	in vhost.h
Date: Mon, 1 Dec 2014 11:18:33 +0200
Message-ID: <20141201091833.GA15607@redhat.com>
References: <1417070481-10331-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1417070481-10331-1-git-send-email-jasowang@redhat.com>
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

On Thu, Nov 27, 2014 at 02:41:21PM +0800, Jason Wang wrote:
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied, thanks.

> ---
>  drivers/vhost/vhost.h | 4 ----
>  1 file changed, 4 deletions(-)
> 
> diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
> index 3eda654..7d039ef 100644
> --- a/drivers/vhost/vhost.h
> +++ b/drivers/vhost/vhost.h
> @@ -12,8 +12,6 @@
>  #include <linux/virtio_ring.h>
>  #include <linux/atomic.h>
>  
> -struct vhost_device;
> -
>  struct vhost_work;
>  typedef void (*vhost_work_fn_t)(struct vhost_work *work);
>  
> @@ -54,8 +52,6 @@ struct vhost_log {
>  	u64 len;
>  };
>  
> -struct vhost_virtqueue;
> -
>  /* The virtqueue structure describes a queue attached to a device. */
>  struct vhost_virtqueue {
>  	struct vhost_dev *dev;
> -- 
> 1.9.1
