From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] vhost: replace % with & on data path
Date: Mon, 30 Nov 2015 00:42:49 -0800
Message-ID: <1448872969.3032.1.camel@perches.com>
References: <1448872427-11623-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448872427-11623-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-11-30 at 10:34 +0200, Michael S. Tsirkin wrote:
> We know vring num is a power of 2, so use &
> to mask the high bits.
[]
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
[]
> @@ -1366,10 +1366,12 @@ int vhost_get_vq_desc(struct vhost_virtqueue *vq,
>  	/* Only get avail ring entries after they have been exposed by guest. */
>  	smp_rmb();
>  
> +	}

?
