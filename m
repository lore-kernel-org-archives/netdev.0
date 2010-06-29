From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 2/2] caif-driver: Add CAIF-SPI Protocol driver.
Date: Tue, 29 Jun 2010 00:10:20 -0700 (PDT)
Message-ID: <20100629.001020.58427550.davem@davemloft.net>
References: <20100625.211223.232914661.davem@davemloft.net>
	<1277587889-17314-1-git-send-email-sjur.brandeland@stericsson.com>
	<1277587889-17314-2-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sjurbr@gmail.com, netdev@vger.kernel.org, marcel@holtmann.org,
	daniel.martensson@stericsson.com, linus.walleij@stericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43141
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752729Ab0F2HKG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 03:10:06 -0400
In-Reply-To: <1277587889-17314-2-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sjur.brandeland@stericsson.com
Date: Sat, 26 Jun 2010 23:31:29 +0200

> From: Sjur Braendeland <sjur.brandeland@stericsson.com>
> 
> This patch introduces the CAIF SPI Protocol Driver for
> CAIF Link Layer.
> 
> This driver implements a platform driver to accommodate for a
> platform specific SPI device. A general platform driver is not
> possible as there are no SPI Slave side Kernel API defined.
> A sample CAIF SPI Platform device can be found in
> .../Documentation/networking/caif/spi_porting.txt
> 
> Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>

Applied, but:

> +
> +config CAIF_SPI_SYNC
> +	bool "Next command and length in start of frame"
> +	depends on CAIF_SPI_SLAVE
> +	default n
> +	---help---
> +	Putting the next command and length in the start of the frame can
> +	help to synchronize to the next transfer in case of over or under-runs.
> +	This option also needs to be enabled on the modem.
> +

This adds an extra new-line at the end of the file, which I corrected
when applying this.

GIT warns when trying to apply a patch with this problem,
checkpatch.pl probably does too, so you really can (in an automated
way) prevent these things from showing up in your submission.
