From: Cornelia Huck <cornelia.huck@de.ibm.com>
Subject: Re: [PATCH 1/6] virtio: wrap find_vqs
Date: Thu, 30 Mar 2017 09:18:41 +0200
Message-ID: <20170330091841.2797eca4.cornelia.huck@de.ibm.com>
References: <1490820507-8005-1-git-send-email-mst@redhat.com>
        <1490820507-8005-2-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
        Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
        kvm@vger.kernel.org, David Airlie <airlied@linux.ie>,
        linux-remoteproc@vger.kernel.org, dri-devel@lists.freedesktop.org,
        Bjorn Andersson <bjorn.andersson@linaro.org>,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        linux-scsi@vger.kernel.org,
        John Fastabend <john.fastabend@gmail.com>,
        Arnd Bergmann <arnd@arndb.de>, Amit Shah <amit@kernel.org>,
        Stefan Hajnoczi <stefanha@redhat.com>,
        virtualization@lists.linux-foundation.org,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1490820507-8005-2-git-send-email-mst@redhat.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 29 Mar 2017 23:48:44 +0300
"Michael S. Tsirkin" <mst@redhat.com> wrote:

> We are going to add more parameters to find_vqs, let's wrap the call so
> we don't need to tweak all drivers every time.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  drivers/block/virtio_blk.c                 | 3 +--
>  drivers/char/virtio_console.c              | 6 +++---
>  drivers/crypto/virtio/virtio_crypto_core.c | 3 +--
>  drivers/gpu/drm/virtio/virtgpu_kms.c       | 3 +--
>  drivers/net/caif/caif_virtio.c             | 3 +--
>  drivers/net/virtio_net.c                   | 3 +--
>  drivers/rpmsg/virtio_rpmsg_bus.c           | 2 +-
>  drivers/scsi/virtio_scsi.c                 | 3 +--
>  drivers/virtio/virtio_balloon.c            | 3 +--
>  drivers/virtio/virtio_input.c              | 3 +--
>  include/linux/virtio_config.h              | 9 +++++++++
>  net/vmw_vsock/virtio_transport.c           | 6 +++---
>  12 files changed, 24 insertions(+), 23 deletions(-)

Regardless whether that context thing is the right thing to do, this
looks like a sensible cleanup.
