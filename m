From: Caleb Raitto <caraitto@google.com>
Subject: RE: [PATCH 1/5] net: virtio dynamically disable/enable LRO
Date: Wed, 18 Oct 2017 19:18:31 -0700
Message-ID: <CA+7y87rYzKSDLb-wq9ok8TqgD_41u8oqZvfWLELYgDqQ4wCrKg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: tgraf@suug.ch, shm@cumulusnetworks.com,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net,
        davem@davemloft.net, netdev@vger.kernel.org, bblanco@plumgrid.com,
        brouer@redhat.com, Catherine Sullivan <csully@google.com>,
        "Michael S. Tsirkin" <mst@redhat.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:54645 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750926AbdJSCSd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 22:18:33 -0400
Received: by mail-wm0-f65.google.com with SMTP id i124so13391713wmf.3
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 19:18:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 18, 2016 at 11:00 AM, John Fastabend
<john.fastabend@gmail.com> wrote:
>
> From: John Fastabend <john.fastabend@gmail.com>
> Date: Fri, Nov 18, 2016 at 11:00 AM
> Subject: [PATCH 1/5] net: virtio dynamically disable/enable LRO
> To: <tgraf@suug.ch>, <shm@cumulusnetworks.com>, <alexei.starovoitov@gmail.com>, <daniel@iogearbox.net>, <davem@davemloft.net>
> Cc: <john.r.fastabend@intel.com>, <netdev@vger.kernel.org>, <bblanco@plumgrid.com>, <john.fastabend@gmail.com>, <brouer@redhat.com>
>
> This adds support for dynamically setting the LRO feature flag. The
> message to control guest features in the backend uses the
> CTRL_GUEST_OFFLOADS msg type.
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  drivers/net/virtio_net.c |   43 +++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 43 insertions(+)
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 2cafd12..0758cae 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -1419,6 +1419,41 @@ static void virtnet_init_settings(struct net_device *dev)

Hi,

I work on Google Compute Engine, and I noticed that you had this
unmerged patch that allows controlling offloads using ethtool for
virtionet.

We are interested in merging this patch as it will be useful in
debugging customer issues related to offloads and MTU.

If work remains to get the patch merged, I'm willing to help out.

Thanks,
-Caleb
