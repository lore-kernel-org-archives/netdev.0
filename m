From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net] virtio-net: fix leaking of ctx array
Date: Fri, 7 Jul 2017 18:48:02 +0300
Message-ID: <20170707184733-mutt-send-email-mst@kernel.org>
References: <1499428569-1608-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1499428569-1608-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 07, 2017 at 07:56:09PM +0800, Jason Wang wrote:
> Fixes: commit d45b897b11ea ("virtio_net: allow specifying context for rx")
> Signed-off-by: Jason Wang <jasowang@redhat.com>


Acked-by: Michael S. Tsirkin <mst@redhat.com>

Needed for stable as well.

Thanks Jason.

> ---
>  drivers/net/virtio_net.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 2e69bcd..99a26a9 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -2229,6 +2229,7 @@ static int virtnet_find_vqs(struct virtnet_info *vi)
>  	kfree(names);
>  	kfree(callbacks);
>  	kfree(vqs);
> +	kfree(ctx);
>  
>  	return 0;
>  
> -- 
> 2.7.4
