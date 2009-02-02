From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH v3 1/4] virtio_net: Add a virtqueue for outbound control commands
Date: Mon, 2 Feb 2009 20:10:54 +1030
Message-ID: <200902022010.54829.rusty@rustcorp.com.au>
References: <20090201200504.8183.58421.stgit@debian.lart> <20090201200509.8183.4996.stgit@debian.lart>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: markmc@redhat.com, netdev@vger.kernel.org, kvm@vger.kernel.org
To: Alex Williamson <alex.williamson@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:58177 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751007AbZBBJk6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Feb 2009 04:40:58 -0500
In-Reply-To: <20090201200509.8183.4996.stgit@debian.lart>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 02 February 2009 06:35:10 Alex Williamson wrote:

> +static bool virtnet_send_command(struct virtnet_info *vi, u8 class, u8 cmd,
> +				 struct scatterlist data[], int out, int in)
> +{
> +	struct scatterlist sg[VIRTIO_NET_MAX_CTRL_ARGS];
...
> diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
> index f76bd4a..f28a72a 100644
> --- a/include/linux/virtio_net.h
> +++ b/include/linux/virtio_net.h
...
> +#define VIRTIO_NET_MAX_CTRL_ARGS   2

I think this definition belongs at the top of virtio_net.c; the others
are userspace-exposed, this is really an internal issue, no?

Other than that, you can add Acked-by: Rusty Russell <rusty@rustcorp.com.au>
and send to netdev for DaveM's tree.

Thanks!
Rusty.
