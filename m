From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 05/13] tile: support PTP using the tilegx mPIPE (IEEE
 1588)
Date: Wed, 24 Jul 2013 08:29:00 +0200
Message-ID: <20130724062900.GB5163@netboy>
References: <cover.1374609948.git.cmetcalf@tilera.com>
 <77f753af79722f39c5fa77cd35adefdd1634e5d5.1374609949.git.cmetcalf@tilera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Chris Metcalf <cmetcalf@tilera.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <77f753af79722f39c5fa77cd35adefdd1634e5d5.1374609949.git.cmetcalf@tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 23, 2013 at 04:05:48PM -0400, Chris Metcalf wrote:

> diff --git a/drivers/ptp/Kconfig b/drivers/ptp/Kconfig
> index 5be73ba..255ed1a 100644
> --- a/drivers/ptp/Kconfig
> +++ b/drivers/ptp/Kconfig
> @@ -87,4 +87,14 @@ config PTP_1588_CLOCK_PCH
>  	  To compile this driver as a module, choose M here: the module
>  	  will be called ptp_pch.
>  
> +config PTP_1588_CLOCK_TILEGX
> +        tristate "Tilera TILE-Gx mPIPE as PTP clock"
> +        select PTP_1588_CLOCK
> +        depends on TILEGX
> +        help
> +          This driver adds support for using the mPIPE as a PTP
> +          clock. This clock is only useful if your PTP programs are
> +          getting hardware time stamps on the PTP Ethernet packets
> +          using the SO_TIMESTAMPING API.
> +

Is this feature available on every TILEGX hardware variant?
If not, then there needs to be some provision for that.

Also, this option should probably appear under the main MAC option.

Thanks,
Richard
