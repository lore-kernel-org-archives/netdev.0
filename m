From: David Miller <davem@redhat.com>
Subject: Re: [PATCH] vhost: replace % with & on data path
Date: Mon, 30 Nov 2015 11:13:17 -0500 (EST)
Message-ID: <20151130.111317.424433109898279987.davem@redhat.com>
References: <1448872427-11623-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448872427-11623-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Mon, 30 Nov 2015 10:34:07 +0200

> We know vring num is a power of 2, so use &
> to mask the high bits.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  drivers/vhost/vhost.c | 8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index 080422f..85f0f0a 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -1366,10 +1366,12 @@ int vhost_get_vq_desc(struct vhost_virtqueue *vq,
>  	/* Only get avail ring entries after they have been exposed by guest. */
>  	smp_rmb();
>  
> +	}
> +

!!!
