From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/1] VSOCK: remove more space available check filling TX
 vq
Date: Fri, 5 Aug 2016 19:53:46 +0300
Message-ID: <69d05004-506c-dbc2-f97e-b71f4945c703@cogentembedded.com>
References: <20160805163420.10092-1-ggarcia@deic.uab.cat>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stefanha@redhat.com, mst@redhat.com
To: ggarcia@abra.uab.cat, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f53.google.com ([209.85.215.53]:34351 "EHLO
	mail-lf0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759965AbcHEQxu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Aug 2016 12:53:50 -0400
Received: by mail-lf0-f53.google.com with SMTP id l69so207663987lfg.1
        for <netdev@vger.kernel.org>; Fri, 05 Aug 2016 09:53:50 -0700 (PDT)
In-Reply-To: <20160805163420.10092-1-ggarcia@deic.uab.cat>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/05/2016 07:34 PM, ggarcia@abra.uab.cat wrote:

> From: Gerard Garcia <ggarcia@deic.uab.cat>
>
> Remove unnecessary use of enable/disable callback notifications
> and the incorrect more space available check.
>
> The virtio_transport_tx_work handles when the TX virtqueue
> has more buffers available.
>
> Signed-off-by: Gerard Garcia <ggarcia@deic.uab.cat>
> ---
>  net/vmw_vsock/virtio_transport.c | 9 ++-------
>  1 file changed, 2 insertions(+), 7 deletions(-)
>
> diff --git a/net/vmw_vsock/virtio_transport.c b/net/vmw_vsock/virtio_transport.c
> index 699dfab..b7a1055 100644
> --- a/net/vmw_vsock/virtio_transport.c
> +++ b/net/vmw_vsock/virtio_transport.c
[...]
> @@ -118,13 +114,12 @@ virtio_transport_send_pkt_work(struct work_struct *work)
>  		}
>
>  		ret = virtqueue_add_sgs(vq, sgs, out_sg, in_sg, pkt, GFP_KERNEL);
> +		/* Usually this means that there is no more space available in
> +		 * the vq */

    The preferred comment style in the networking code is:

/* bla
  * bla
  */

[...]

MBR, Sergei
