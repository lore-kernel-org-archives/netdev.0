From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 4/4] net, virtio_net: replace the magic value
Date: Mon, 18 Nov 2013 11:50:43 +0200
Message-ID: <20131118095043.GA3470@redhat.com>
References: <1384764380-16832-1-git-send-email-zwu.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, qemu-devel@nongnu.org,
	rusty@rustcorp.com.au, Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>,
	linux-kernel@vger.kernel.org
To: Zhi Yong Wu <zwu.kernel@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1384764380-16832-1-git-send-email-zwu.kernel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 18, 2013 at 04:46:20PM +0800, Zhi Yong Wu wrote:
> From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
> 
> It is more appropriate to use # of queue pairs currently used by
> the driver instead of a magic value.
> 
> Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

I don't mind, but driver should be submitted separately
from qemu patches. As it is only patch 4/4 made it to netdev.

> ---
>  drivers/net/virtio_net.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index cdc7c90..e0cb2d1 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -1619,8 +1619,8 @@ static int virtnet_probe(struct virtio_device *vdev)
>  	if (err)
>  		goto free_stats;
>  
> -	netif_set_real_num_tx_queues(dev, 1);
> -	netif_set_real_num_rx_queues(dev, 1);
> +	netif_set_real_num_tx_queues(dev, vi->curr_queue_pairs);
> +	netif_set_real_num_rx_queues(dev, vi->curr_queue_pairs);
>  
>  	err = register_netdev(dev);
>  	if (err) {
> -- 
> 1.7.6.5
> 
