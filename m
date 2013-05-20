From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/5] drivers: net: usb: rtl8150: moving constant and
 structure definitions out of rtl8150.c
Date: Mon, 20 May 2013 15:49:20 +0100
Message-ID: <1369061360.4616.0.camel@bwh-desktop.uk.solarflarecom.com>
References: <alpine.DEB.2.02.1305182306550.16874@fry.nucleusys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Petko Manolov <petkan@nucleusys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1305182306550.16874@fry.nucleusys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2013-05-18 at 23:20 +0300, Petko Manolov wrote:
> From: Petko Manolov <petkan@nucleusys.com>
> 
> Moving constant and structure definitions out of rtl8150.c;
> 
> Signed-off-by: Petko Manolov <petkan@nucleusys.com>
> ---
>  drivers/net/usb/rtl8150.c |  121 +----------------------------------
>  1 file changed, 2 insertions(+), 119 deletions(-)
> 
> diff --git a/drivers/net/usb/rtl8150.c b/drivers/net/usb/rtl8150.c
> index a491d3a..7d1897b 100644
> --- a/drivers/net/usb/rtl8150.c
> +++ b/drivers/net/usb/rtl8150.c
> @@ -17,132 +17,15 @@
>  #include <linux/usb.h>
>  #include <asm/uaccess.h>
>  
> +#include "rtl8150.h"
[...]

Now how is this driver going to compile, when rtl8150.h is only added by
the next patch?!

You need to squash these first 2 together, so that the driver can be
compiled after each step.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
