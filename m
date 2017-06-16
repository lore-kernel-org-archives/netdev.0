From: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
Subject: remove dma_alloc_noncoherent
Date: Fri, 16 Jun 2017 09:17:05 +0200
Message-ID: <20170616071716.17321-1-hch@lst.de>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        nios2-dev-g9ZBwUv/Ih/yUk5EbOjzuce+I+R0W71w@public.gmane.org, linux-fbdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org
Return-path: <linux-metag-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-metag-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

For many years we've had the dma_alloc_attrs API that is more flexible
than dma_alloc_noncoherent.  This series moves the remaining users over
to the attrs API.
