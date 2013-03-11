From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH -next] vhost-blk: remove unused variable
Date: Mon, 11 Mar 2013 16:44:55 +0200
Message-ID: <20130311144455.GA27441@redhat.com>
References: <CAPgLHd-eRBB2xCP7-ZswjfEKXPY29G1Nv71DzGo_-=TVym8MNQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yongjun_wei@trendmicro.com.cn, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53264 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751647Ab3CKOoh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Mar 2013 10:44:37 -0400
Content-Disposition: inline
In-Reply-To: <CAPgLHd-eRBB2xCP7-ZswjfEKXPY29G1Nv71DzGo_-=TVym8MNQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 11, 2013 at 10:39:27PM +0800, Wei Yongjun wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> The variable vq is initialized but never used
> otherwise, so remove the unused variable.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Which branch does this target?

> ---
>  drivers/vhost/blk.c | 3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/drivers/vhost/blk.c b/drivers/vhost/blk.c
> index 658c5f9..d9b245b 100644
> --- a/drivers/vhost/blk.c
> +++ b/drivers/vhost/blk.c
> @@ -419,8 +419,6 @@ static void vhost_blk_handle_guest_kick(struct vhost_work *work)
>  /* Host kick us for I/O completion */
>  static void vhost_blk_handle_host_kick(struct vhost_work *work)
>  {
> -
> -	struct vhost_virtqueue *vq;
>  	struct vhost_blk_req *req;
>  	struct llist_node *llnode;
>  	struct vhost_blk *blk;
> @@ -429,7 +427,6 @@ static void vhost_blk_handle_host_kick(struct vhost_work *work)
>  	int ret;
>  
>  	blk = container_of(work, struct vhost_blk, work);
> -	vq = &blk->vq;
>  
>  	llnode = llist_del_all(&blk->llhead);
>  	added = false;
