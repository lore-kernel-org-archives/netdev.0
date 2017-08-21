From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH 1/2] vhost: remove the possible fruitless search on iotlb
 prefetch
Date: Mon, 21 Aug 2017 11:09:00 +0800
Message-ID: <3e8361c3-8a1b-6f30-80a1-1d45dabfdc39@redhat.com>
References: <20170819064114.27219-1-den@klaipeden.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
        netdev@vger.kernel.org
To: Koichiro Den <den@klaipeden.com>, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35034 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750742AbdHUDJH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 20 Aug 2017 23:09:07 -0400
In-Reply-To: <20170819064114.27219-1-den@klaipeden.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年08月19日 14:41, Koichiro Den wrote:
> Signed-off-by: Koichiro Den <den@klaipeden.com>
> ---
>   drivers/vhost/vhost.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index e4613a3c362d..93e909afc1c3 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -1184,7 +1184,7 @@ static int iotlb_access_ok(struct vhost_virtqueue *vq,
>   	while (len > s) {
>   		node = vhost_umem_interval_tree_iter_first(&umem->umem_tree,
>   							   addr,
> -							   addr + len - 1);
> +							   addr + len - s - 1);
>   		if (node == NULL || node->start > addr) {
>   			vhost_iotlb_miss(vq, addr, access);
>   			return false;

Acked-by: Jason Wang <jasowang@redhat.com>
