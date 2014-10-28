From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH RFC 4/4] virtio_net: bigger header when VERSION_1 is set
Date: Tue, 28 Oct 2014 10:58:39 +1030
Message-ID: <87wq7l9gw8.fsf@rustcorp.com.au>
References: <1414099656-28090-1-git-send-email-mst@redhat.com>
	<1414099656-28090-2-git-send-email-mst@redhat.com>
	<1414099656-28090-3-git-send-email-mst@redhat.com>
	<1414099656-28090-4-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1414099656-28090-4-git-send-email-mst@redhat.com>
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

"Michael S. Tsirkin" <mst@redhat.com> writes:
> With VERSION_1 virtio_net uses same header size
> whether mergeable buffers are enabled or not.
>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

These two are great too, thanks:

Acked-by: Rusty Russell <rusty@rustcorp.com.au>

Cheers,
Rusty.

> ---
>  drivers/net/virtio_net.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 9c6d50f..a2fe340 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -1764,7 +1764,8 @@ static int virtnet_probe(struct virtio_device *vdev)
>  	if (virtio_has_feature(vdev, VIRTIO_NET_F_MRG_RXBUF))
>  		vi->mergeable_rx_bufs = true;
>  
> -	if (virtio_has_feature(vdev, VIRTIO_NET_F_MRG_RXBUF))
> +	if (virtio_has_feature(vdev, VIRTIO_NET_F_MRG_RXBUF) ||
> +	    virtio_has_feature(vdev, VIRTIO_F_VERSION_1))
>  		vi->hdr_len = sizeof(struct virtio_net_hdr_mrg_rxbuf);
>  	else
>  		vi->hdr_len = sizeof(struct virtio_net_hdr);
> -- 
> MST
