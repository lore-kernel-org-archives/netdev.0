From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH take 2] Atmel MACB ethernet driver
Date: Tue, 14 Nov 2006 10:43:46 -0500
Message-ID: <4559E432.9070401@pobox.com>
References: <20061109145117.577e3c61@cad-250-152.norway.atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Victor <andrew@sanpeople.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57536 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S966030AbWKNPnw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Nov 2006 10:43:52 -0500
To: Haavard Skinnemoen <hskinnemoen@atmel.com>
In-Reply-To: <20061109145117.577e3c61@cad-250-152.norway.atmel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Haavard Skinnemoen wrote:
> Driver for the Atmel MACB on-chip ethernet module.
> 
> Tested on AVR32/AT32AP7000/ATSTK1000. I've heard rumours that it works
> with AT91SAM9260 as well, and it may be possible to share some code with
> the at91_ether driver for AT91RM9200.
> 
> Hardware documentation can be found in the AT32AP7000 data sheet,
> which can be downloaded from
> 
> http://www.atmel.com/dyn/products/datasheets.asp?family_id=682
> 
> Changes since previous version:
>   * Probe for PHY ID instead of depending on it being provided through
>     platform_data.
>   * Grab initial ethernet address from the MACB registers instead
>     of depending on platform_data.
>   * Set MII/RMII mode correctly.
> 
> These changes are mostly about making the driver more compatible with
> the at91 infrastructure.
> 
> Signed-off-by: Haavard Skinnemoen <hskinnemoen@atmel.com>

applied.

Thanks for submitting a nice, clean driver that was so painless to apply 
to the latest kernel.

I wish all vendors were as effective and efficient.

	Jeff



