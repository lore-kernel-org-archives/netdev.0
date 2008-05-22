From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/2] VIRTIO: Use __skb_queue_purge()
Date: Thu, 22 May 2008 14:01:20 -0400
Message-ID: <4835B4F0.7000702@pobox.com>
References: <483545EF.3070501@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	"David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36634 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755578AbYEVSBa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 14:01:30 -0400
In-Reply-To: <483545EF.3070501@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen wrote:
> Use standard routine for queue purging.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> ---
>  drivers/net/virtio_net.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index f926b5a..fe7cdf2 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -470,8 +470,7 @@ static void virtnet_remove(struct virtio_device *vdev)
>  		kfree_skb(skb);
>  		vi->num--;
>  	}
> -	while ((skb = __skb_dequeue(&vi->send)) != NULL)
> -		kfree_skb(skb);
> +	__skb_queue_purge(&vi->send);
>  

applied 1-2


