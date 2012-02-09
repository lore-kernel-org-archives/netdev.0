From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 42/50] virtio_net:  use dev_hw_addr_random() instead of
	random_ether_addr()
Date: Thu, 9 Feb 2012 11:35:59 +0200
Message-ID: <20120209093559.GA903@redhat.com>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
	<1328735457-29986-43-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Danny Kukawka <dkukawka@suse.de>,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	"David S. Miller" <davem@davemloft.net>
To: Danny Kukawka <danny.kukawka@bisect.de>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1328735457-29986-43-git-send-email-danny.kukawka@bisect.de>
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

On Wed, Feb 08, 2012 at 10:10:49PM +0100, Danny Kukawka wrote:
> Use dev_hw_addr_random() instead of calling random_ether_addr()
> to set addr_assign_type correctly to NET_ADDR_RANDOM.
> 
> Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
>  drivers/net/virtio_net.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 4880aa8..69d36e1 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -1061,7 +1061,7 @@ static int virtnet_probe(struct virtio_device *vdev)
>  	if (virtio_config_val_len(vdev, VIRTIO_NET_F_MAC,
>  				  offsetof(struct virtio_net_config, mac),
>  				  dev->dev_addr, dev->addr_len) < 0)
> -		random_ether_addr(dev->dev_addr);
> +		dev_hw_addr_random(dev, dev->dev_addr);
>  
>  	/* Set up our device-specific information */
>  	vi = netdev_priv(dev);
> -- 
> 1.7.7.3
