From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 0/5] virtio 1.0 cleanups and one fix.
Date: Sun, 8 Feb 2015 10:52:34 +0100
Message-ID: <20150208095234.GA3185@redhat.com>
References: <1423199216-2094-1-git-send-email-rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lkml <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1423199216-2094-1-git-send-email-rusty@rustcorp.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 06, 2015 at 03:36:51PM +1030, Rusty Russell wrote:
> Hi all,
> 
> 	Some minor fixes for my virtio-next tree.  Michael, does
> QEMU implement the (compuslory!) VIRTIO_PCI_CAP_PCI_CFG field?  I'm
> guessing not, since it wasn't defined in the Linux header :(

Not yet, thanks for the reminder.
BIOS is going to use that one so you can be sure
it'll be there when support is merged finally.

> Rusty Russell (5):
>   virtio: define VIRTIO_PCI_CAP_PCI_CFG in header.
>   virtio: Don't expose legacy block features when VIRTIO_BLK_NO_LEGACY
>     defined.
>   virtio: Don't expose legacy net features when VIRTIO_NET_NO_LEGACY
>     defined.
>   virtio: Don't expose legacy config features when
>     VIRTIO_CONFIG_NO_LEGACY defined.
>   virtio: don't require a config space on the console device.
> 
>  drivers/char/virtio_console.c      | 12 ++++++++----
>  include/uapi/linux/virtio_blk.h    | 17 +++++++++++++----
>  include/uapi/linux/virtio_config.h |  2 ++
>  include/uapi/linux/virtio_net.h    | 30 ++++++++++++++++++++++++++++--
>  include/uapi/linux/virtio_pci.h    |  4 +++-
>  5 files changed, 54 insertions(+), 11 deletions(-)
> 
> -- 
> 2.1.0
