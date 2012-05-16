From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] ptp_pch: Add missing #include <linux/slab.h>
Date: Wed, 16 May 2012 19:19:49 +0200
Message-ID: <20120516171949.GB3587@netboy.at.omicron.at>
References: <1337169017-15835-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Takahiro Shimizu <tshimizu818@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1337169017-15835-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 16, 2012 at 01:50:17PM +0200, Geert Uytterhoeven wrote:
> drivers/ptp/ptp_pch.c: In function 'pch_remove':
> drivers/ptp/ptp_pch.c:576:2: error: implicit declaration of function 'kfree' [-Werror=implicit-function-declaration]
> drivers/ptp/ptp_pch.c: In function 'pch_probe':
> drivers/ptp/ptp_pch.c:587:2: error: implicit declaration of function 'kzalloc' [-Werror=implicit-function-declaration]
> 
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>

Acked-by: Richard Cochran <richardcochran@gmail.com>

Thanks,
Richard

> ---
> Not even compile-tested, as it fails on parisc only.
> http://kisskb.ellerman.id.au/kisskb/buildresult/6312813/
> 
>  drivers/ptp/ptp_pch.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/ptp/ptp_pch.c b/drivers/ptp/ptp_pch.c
> index 375eb04..6fff680 100644
> --- a/drivers/ptp/ptp_pch.c
> +++ b/drivers/ptp/ptp_pch.c
> @@ -30,6 +30,7 @@
>  #include <linux/module.h>
>  #include <linux/pci.h>
>  #include <linux/ptp_clock_kernel.h>
> +#include <linux/slab.h>
>  
>  #define STATION_ADDR_LEN	20
>  #define PCI_DEVICE_ID_PCH_1588	0x8819
> -- 
> 1.7.0.4
> 
