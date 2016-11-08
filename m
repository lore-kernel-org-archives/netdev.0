From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v4] Net Driver: Add Cypress GX3 VID=04b4 PID=3610.
Date: Tue, 8 Nov 2016 07:48:42 +0100
Message-ID: <20161108064842.GB13024@kroah.com>
References: <CAPZMiRa0kYyPFQ77L5y4NgxxH85iuMAjODV2iCzd-5OjyGfNuw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Allan Chou <allan@asix.com.tw>,
        Artjom Simon <artjom.simon@gmail.com>
To: Chris Roth <chris.roth@usask.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:39380 "EHLO
        mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753534AbcKHGsf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2016 01:48:35 -0500
Content-Disposition: inline
In-Reply-To: <CAPZMiRa0kYyPFQ77L5y4NgxxH85iuMAjODV2iCzd-5OjyGfNuw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 07, 2016 at 04:44:20PM -0600, Chris Roth wrote:
> From: Allan Chou <allan@asix.com.tw>
> 
> Add support for Cypress GX3 SuperSpeed to Gigabit Ethernet
> Bridge Controller (Vendor=04b4 ProdID=3610).
> 
> Patch verified on x64 linux kernel 4.7.4, 4.8.6, 4.9-rc4 systems
> with the Kensington SD4600P USB-C Universal Dock with Power,
> which uses the Cypress GX3 SuperSpeed to Gigabit Ethernet Bridge
> Controller.
> 
> A similar patch was signed-off and tested-by Allan Chou
> <allan@asix.com.tw> on 2015-12-01.
> 
> Allan verified his similar patch on x86 Linux kernel 4.1.6 system
> with Cypress GX3 SuperSpeed to Gigabit Ethernet Bridge Controller.
> 
> Tested-by: Allan Chou <allan@asix.com.tw>
> Tested-by: Chris Roth <chris.roth@usask.ca>
> Tested-by: Artjom Simon <artjom.simon@gmail.com>
> 
> Signed-off-by: Allan Chou <allan@asix.com.tw>
> Signed-off-by: Chris Roth <chris.roth@usask.ca>
> ---
>  drivers/net/usb/ax88179_178a.c | 17 +++++++++++++++++
>  1 file changed, 17 insertions(+)
> 
> diff --git a/drivers/net/usb/ax88179_178a.c b/drivers/net/usb/ax88179_178a.c
> index e6338c1..8a6675d 100644
> --- a/drivers/net/usb/ax88179_178a.c
> +++ b/drivers/net/usb/ax88179_178a.c
> @@ -1656,6 +1656,19 @@ static const struct driver_info ax88178a_info = {
>      .tx_fixup = ax88179_tx_fixup,
>  };
> 
> +static const struct driver_info cypress_GX3_info = {
> +    .description = "Cypress GX3 SuperSpeed to Gigabit Ethernet Controller",
> +    .bind = ax88179_bind,
> +    .unbind = ax88179_unbind,
> +    .status = ax88179_status,
> +    .link_reset = ax88179_link_reset,
> +    .reset = ax88179_reset,
> +    .stop = ax88179_stop,
> +    .flags = FLAG_ETHER | FLAG_FRAMING_AX,
> +    .rx_fixup = ax88179_rx_fixup,
> +    .tx_fixup = ax88179_tx_fixup,
> +};

Your tabs got eaten and converted to spaces, making this patch
impossible to apply :(

And you forgot to list what changed from v3, please put that below the
--- line.

thanks,

greg k-h
