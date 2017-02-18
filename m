From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [RFC v2 00/20] Replace PCI pool by DMA pool API
Date: Sat, 18 Feb 2017 14:06:00 +0100
Message-ID: <20170218130600.GA24938@kroah.com>
References: <20170218083556.20215-1-romain.perier@collabora.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dan.j.williams@intel.com>,
        Doug Ledford <dledford@redhat.com>,
        Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        jeffrey.t.kirsher@intel.com,
        "David S. Miller" <davem@davemloft.net>, stas.yakovlev@gmail.com,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        Felipe Balbi <balbi@kernel.org>, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, linux-usb@vger.kernel.org,
        linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org,
        Peter Senna Tschudin <peter.senna@collabora.co.uk>
To: Romain Perier <romain.perier@collabora.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170218083556.20215-1-romain.perier@collabora.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Feb 18, 2017 at 09:35:36AM +0100, Romain Perier wrote:
> The current PCI pool API are simple macro functions direct expanded to
> the appropriated dma pool functions. The prototypes are almost the same
> and semantically, they are very similar. I propose to use the DMA pool
> API directly and get rid of the old API.
> 
> This set of patches, replaces the old API by the dma pool API, adds
> support to warn about this old API in checkpath.pl and remove the
> defines.

Why is this a "RFC" series?  Personally, I never apply those as it
implies that the author doesn't think they are ready to be merged :)

thanks,

greg k-h
