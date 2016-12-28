From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [RFC PATCH net-next v4 1/2] macb: Add 1588 support in Cadence
 GEM.
Date: Wed, 28 Dec 2016 09:15:25 +0100
Message-ID: <20161228081524.GA3826@netboy>
References: <1481720175-12703-1-git-send-email-andrei.pistirica@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, davem@davemloft.net,
        nicolas.ferre@atmel.com, harinikatakamlinux@gmail.com,
        harini.katakam@xilinx.com, punnaia@xilinx.com, michals@xilinx.com,
        anirudh@xilinx.com, boris.brezillon@free-electrons.com,
        alexandre.belloni@free-electrons.com, tbultel@pixelsurmer.com,
        rafalo@cadence.com
To: Andrei Pistirica <andrei.pistirica@microchip.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1481720175-12703-1-git-send-email-andrei.pistirica@microchip.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 14, 2016 at 02:56:14PM +0200, Andrei Pistirica wrote:
> Note 1: Kbuild uses "select" instead of "imply", and the macb maintainer agreed
>         to make the change when it will be available in net-next.

> +config MACB_USE_HWSTAMP
> +	bool "Use IEEE 1588 hwstamp"
> +	depends on MACB
> +	default y
> +	select PTP_1588_CLOCK

The imply key word has been merged as of:

    237e3ad Kconfig: Introduce the "imply" keyword

Please use it.

Thanks,
Richard


> +	---help---
> +	  Enable IEEE 1588 Precision Time Protocol (PTP) support for MACB.
