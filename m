From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH -next 1/2] virtio: Start feature MTU support
Date: Thu, 2 Jun 2016 19:17:17 +0300
Message-ID: <20160602191702-mutt-send-email-mst@redhat.com>
References: <1464882211-18723-1-git-send-email-aconole@redhat.com>
 <1464882211-18723-2-git-send-email-aconole@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Aaron Conole <aconole@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1464882211-18723-2-git-send-email-aconole@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 02, 2016 at 11:43:30AM -0400, Aaron Conole wrote:
> This commit adds the feature bit and associated mtu device entry for the
> virtio network device. Future commits will make use of these bits to
> support negotiated MTU.

why split it out? Pls squash with the next patch.

> Signed-off-by: Aaron Conole <aconole@redhat.com>
> ---
>  include/uapi/linux/virtio_net.h | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/include/uapi/linux/virtio_net.h b/include/uapi/linux/virtio_net.h
> index ec32293..751ff59 100644
> --- a/include/uapi/linux/virtio_net.h
> +++ b/include/uapi/linux/virtio_net.h
> @@ -73,6 +73,8 @@ struct virtio_net_config {
>  	 * Legal values are between 1 and 0x8000
>  	 */
>  	__u16 max_virtqueue_pairs;
> +	/* Default maximum transmit unit advice */
> +	__u16 mtu;
>  } __attribute__((packed));
>  
>  /*
> -- 
> 2.5.5
