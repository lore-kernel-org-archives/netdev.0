From: Peter Senna Tschudin <peter.senna@collabora.com>
Subject: Re: [PATCH v3 18/20] usb: host: Remove remaining pci_pool in comments
Date: Mon, 27 Feb 2017 12:20:00 +0100
Message-ID: <20170227112000.GI26544@collabora.com>
References: <20170226192425.13098-1-romain.perier@collabora.com>
 <20170226192425.13098-19-romain.perier@collabora.com>
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
        Felipe Balbi <balbi@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org, linux-scsi@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Peter Senna Tschudin <peter.senna@collabora.co.uk>
To: Romain Perier <romain.perier@collabora.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([46.235.227.227]:36387 "EHLO
        bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751617AbdB0LWf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 06:22:35 -0500
Content-Disposition: inline
In-Reply-To: <20170226192425.13098-19-romain.perier@collabora.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 26, 2017 at 08:24:23PM +0100, Romain Perier wrote:
> This replaces remaining occurences of pci_pool by dma_pool, as
> this is the new API that could be used for that purpose.
> 
Reviewed-by: Peter Senna Tschudin <peter.senna@collabora.com>
> Signed-off-by: Romain Perier <romain.perier@collabora.com>
> ---
>  drivers/usb/host/ehci-hcd.c     | 2 +-
>  drivers/usb/host/fotg210-hcd.c  | 2 +-
>  drivers/usb/host/oxu210hp-hcd.c | 2 +-
>  3 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/usb/host/ehci-hcd.c b/drivers/usb/host/ehci-hcd.c
> index ac2c4ea..6e834b83 100644
> --- a/drivers/usb/host/ehci-hcd.c
> +++ b/drivers/usb/host/ehci-hcd.c
> @@ -597,7 +597,7 @@ static int ehci_run (struct usb_hcd *hcd)
>  	/*
>  	 * hcc_params controls whether ehci->regs->segment must (!!!)
>  	 * be used; it constrains QH/ITD/SITD and QTD locations.
> -	 * pci_pool consistent memory always uses segment zero.
> +	 * dma_pool consistent memory always uses segment zero.
>  	 * streaming mappings for I/O buffers, like pci_map_single(),
>  	 * can return segments above 4GB, if the device allows.
>  	 *
> diff --git a/drivers/usb/host/fotg210-hcd.c b/drivers/usb/host/fotg210-hcd.c
> index 1c5b34b..ced08dc 100644
> --- a/drivers/usb/host/fotg210-hcd.c
> +++ b/drivers/usb/host/fotg210-hcd.c
> @@ -5047,7 +5047,7 @@ static int fotg210_run(struct usb_hcd *hcd)
>  	/*
>  	 * hcc_params controls whether fotg210->regs->segment must (!!!)
>  	 * be used; it constrains QH/ITD/SITD and QTD locations.
> -	 * pci_pool consistent memory always uses segment zero.
> +	 * dma_pool consistent memory always uses segment zero.
>  	 * streaming mappings for I/O buffers, like pci_map_single(),
>  	 * can return segments above 4GB, if the device allows.
>  	 *
> diff --git a/drivers/usb/host/oxu210hp-hcd.c b/drivers/usb/host/oxu210hp-hcd.c
> index bcf531c..ed20fb3 100644
> --- a/drivers/usb/host/oxu210hp-hcd.c
> +++ b/drivers/usb/host/oxu210hp-hcd.c
> @@ -2708,7 +2708,7 @@ static int oxu_run(struct usb_hcd *hcd)
>  
>  	/* hcc_params controls whether oxu->regs->segment must (!!!)
>  	 * be used; it constrains QH/ITD/SITD and QTD locations.
> -	 * pci_pool consistent memory always uses segment zero.
> +	 * dma_pool consistent memory always uses segment zero.
>  	 * streaming mappings for I/O buffers, like pci_map_single(),
>  	 * can return segments above 4GB, if the device allows.
>  	 *
> -- 
> 2.9.3
> 
