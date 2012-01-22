From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 1/2] virtio: fix typos of memory barriers
Date: Sun, 22 Jan 2012 13:47:46 +0200
Message-ID: <20120122114746.GC27222@redhat.com>
References: <20120120081658.50747.10625.stgit@amd-6168-8-1.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20120120081658.50747.10625.stgit@amd-6168-8-1.englab.nay.redhat.com>
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

On Fri, Jan 20, 2012 at 04:16:59PM +0800, Jason Wang wrote:
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Good catch.
Note: this fixes a bug introduced by
7b21e34fd1c272e3a8c3846168f2f6287a4cd72b.
It's probably a good idea to mention
this is the commit log.

Acked-by: Michael S. Tsirkin <mst@redhat.com>



> ---
>  drivers/virtio/virtio_ring.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
> index 79e1b29..78428a8 100644
> --- a/drivers/virtio/virtio_ring.c
> +++ b/drivers/virtio/virtio_ring.c
> @@ -35,7 +35,7 @@
>  #define virtio_rmb(vq) \
>  	do { if ((vq)->weak_barriers) smp_rmb(); else rmb(); } while(0)
>  #define virtio_wmb(vq) \
> -	do { if ((vq)->weak_barriers) smp_rmb(); else rmb(); } while(0)
> +	do { if ((vq)->weak_barriers) smp_wmb(); else wmb(); } while(0)
>  #else
>  /* We must force memory ordering even if guest is UP since host could be
>   * running on another CPU, but SMP barriers are defined to barrier() in that
