From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] virtio_net: Set VIRTIO_NET_F_GUEST_CSUM feature
Date: Fri, 11 Jul 2008 01:22:22 -0400
Message-ID: <4876EE0E.1000400@garzik.org>
References: <200807081710.42530.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:49686 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755437AbYGKFWa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jul 2008 01:22:30 -0400
In-Reply-To: <200807081710.42530.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rusty Russell wrote:
> From: Mark McLoughlin <markmc@redhat.com>
> 
> We can handle receiving partial csums, so set the
> appropriate feature bit.
> 
> Signed-off-by: Mark McLoughlin <markmc@redhat.com>
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> ---
>  drivers/net/virtio_net.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -550,7 +550,8 @@ static struct virtio_device_id id_table[
>  };
>  
>  static unsigned int features[] = {
> -	VIRTIO_NET_F_CSUM, VIRTIO_NET_F_GSO, VIRTIO_NET_F_MAC,
> +	VIRTIO_NET_F_CSUM, VIRTIO_NET_F_GUEST_CSUM,
> +	VIRTIO_NET_F_GSO, VIRTIO_NET_F_MAC,
>  	VIRTIO_NET_F_HOST_TSO4, VIRTIO_NET_F_HOST_UFO, VIRTIO_NET_F_HOST_TSO6,
>  	VIRTIO_NET_F_HOST_ECN, VIRTIO_F_NOTIFY_ON_EMPTY,
>  };
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in

applied


