From: Doug Ledford <dledford@redhat.com>
Subject: Re: [PATCH v6 06/15] mlx5: Replace PCI pool old API
Date: Fri, 24 Mar 2017 23:47:24 -0400
Message-ID: <1490413644.2404.46.camel@redhat.com>
References: <20170319170404.17362-1-romain.perier@collabora.com>
         <20170319170404.17362-7-romain.perier@collabora.com>
         <20170320063109.GT2079@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Dan Williams <dan.j.williams@intel.com>,
        Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        jeffrey.t.kirsher@intel.com,
        "David S. Miller" <davem@davemloft.net>, stas.yakovlev@gmail.com,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        Felipe Balbi <balbi@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org, linux-scsi@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Peter Senna Tschudin <peter.senna@collabora.co.uk>
To: Leon Romanovsky <leon@kernel.org>,
        Romain Perier <romain.perier@collabora.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20170320063109.GT2079@mtr-leonro.local>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-03-20 at 08:31 +0200, Leon Romanovsky wrote:
> On Sun, Mar 19, 2017 at 06:03:55PM +0100, Romain Perier wrote:
> > 
> > The PCI pool API is deprecated. This commit replaces the PCI pool
> > old
> > API by the appropriate function with the DMA pool API.
> > 
> > Signed-off-by: Romain Perier <romain.perier@collabora.com>
> > Reviewed-by: Peter Senna Tschudin <peter.senna@collabora.com>
> > ---
> >  drivers/net/ethernet/mellanox/mlx5/core/cmd.c | 11 ++++++-----
> >  include/linux/mlx5/driver.h                   |  2 +-
> >  2 files changed, 7 insertions(+), 6 deletions(-)
> > 
> 
> Thanks,
> Acked-by: Leon Romanovsky <leonro@mellanox.com>

Changes look fine to me, and in addition I've compiled and tested them
on mlx5 hardware and verified that RDMA communications still work.

Acked-by: Doug Ledford <dledford@redhat.com>
Tested-by: Doug Ledford <dledford@redhat.com>

-- 
Doug Ledford <dledford@redhat.com>
    GPG KeyID: B826A3330E572FDD
   
Key fingerprint = AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FDD
