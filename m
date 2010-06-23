From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] phylib: Add autoload support for the LXT973 phy.
Date: Wed, 23 Jun 2010 07:37:23 +0200
Message-ID: <20100623053723.GA3404@riccoc20.at.omicron.at>
References: <20100531130932.GA15845@riccoc20.at.omicron.at>
 <1277210293.21798.11.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:37792 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751327Ab0FWFh1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jun 2010 01:37:27 -0400
Received: by fg-out-1718.google.com with SMTP id d23so1510490fga.1
        for <netdev@vger.kernel.org>; Tue, 22 Jun 2010 22:37:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1277210293.21798.11.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 22, 2010 at 01:38:13PM +0100, David Woodhouse wrote:
> prefer that we just remember to update the table and don't need to be
> forced :)

Oops, and thanks for catching this.

>  static struct mdio_device_id lxt_tbl[] = {
>  	{ 0x78100000, 0xfffffff0 },
>  	{ 0x001378e0, 0xfffffff0 },
> +	{ 0x00137a10, 0xfffffff0 },
>  	{ }
>  };

Question about the whole PHY MODULE_DEVICE_TABLE system:

I recently posted a phy driver for the National Semiconductor
DP83640. During development, I used drivers/net/arm/ixp4xx_eth.c as
the MAC driver, which was linked into the kernel (not a module). I
noticed that the phy driver's probe function only gets called if the
phy driver is also statically linked, but not when it is loaded as a
module.

Is this the correct behavior?

Thanks,

Richard
