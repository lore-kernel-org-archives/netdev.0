From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v2] tile: support PTP using the tilegx mPIPE (IEEE 1588)
Date: Thu, 25 Jul 2013 19:55:42 +0200
Message-ID: <20130725175542.GD4619@netboy>
References: <20130724062533.GA5163@netboy>
 <cover.1374609948.git.cmetcalf@tilera.com>
 <77f753af79722f39c5fa77cd35adefdd1634e5d5.1374609949.git.cmetcalf@tilera.com>
 <201307251525.r6PFP7Ox030354@farm-0012.internal.tilera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Chris Metcalf <cmetcalf@tilera.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201307251525.r6PFP7Ox030354@farm-0012.internal.tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 25, 2013 at 11:19:38AM -0400, Chris Metcalf wrote:
> Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
> ---
> v2:
>  - Moved Kconfig stanza to drivers/ethernet/tile/Kconfig
>  - Clarify minimum and maximum frequency adjustments

So if the requested frequency adjustment lies within the +/-30 ppm
interval, then you return EINVAL? Maybe ERANGE would be better.
Perhaps the driver should just round to the closest value it can
support? Unfortunately, we don't have a way to communicate this kind
of limitation to user space.

>  - Merge PTP support into tilegx.c driver source code directly
>  - Support SIOCSHWTSTAMP ioctl appopriately
>  - Rebased to be the last patch in the series to simplify development

Anyhow, this looks much better to me now.

Acked-by: Richard Cochran <richardcochran@gmail.com>
