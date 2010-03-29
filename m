From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: Re: [PATCH 09/17] pcmcia: update gfp/slab.h includes
Date: Mon, 29 Mar 2010 21:32:03 +0200
Message-ID: <20100329193203.GA8450@comet.dominikbrodowski.net>
References: <1269885165-18617-1-git-send-email-tj@kernel.org>
 <1269885165-18617-10-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sfr@canb.auug.org.au, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1269885165-18617-10-git-send-email-tj@kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 30, 2010 at 02:52:37AM +0900, Tejun Heo wrote:
> Implicit slab.h inclusion via percpu.h is about to go away.  Make sure
> gfp.h or slab.h is included as necessary.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Stephen Rothwell <sfr@canb.auug.org.au>
> Cc: Dominik Brodowski <linux@dominikbrodowski.net>
Acked-by: Dominik Brodowski <linux@dominikbrodowski.net>


> ---
>  drivers/isdn/hardware/avm/avm_cs.c |    1 -
>  drivers/pcmcia/pcmcia_cis.c        |    1 +
>  drivers/pcmcia/rsrc_iodyn.c        |    1 +
>  3 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/isdn/hardware/avm/avm_cs.c b/drivers/isdn/hardware/avm/avm_cs.c
> index 8bbc452..f410d0e 100644
> --- a/drivers/isdn/hardware/avm/avm_cs.c
> +++ b/drivers/isdn/hardware/avm/avm_cs.c
> @@ -13,7 +13,6 @@
>  #include <linux/kernel.h>
>  #include <linux/init.h>
>  #include <linux/ptrace.h>
> -#include <linux/slab.h>
>  #include <linux/string.h>
>  #include <linux/tty.h>
>  #include <linux/serial.h>
> diff --git a/drivers/pcmcia/pcmcia_cis.c b/drivers/pcmcia/pcmcia_cis.c
> index 7406387..4a65eaf 100644
> --- a/drivers/pcmcia/pcmcia_cis.c
> +++ b/drivers/pcmcia/pcmcia_cis.c
> @@ -14,6 +14,7 @@
>   *
>   */
>  
> +#include <linux/slab.h>
>  #include <linux/module.h>
>  #include <linux/kernel.h>
>  #include <linux/netdevice.h>
> diff --git a/drivers/pcmcia/rsrc_iodyn.c b/drivers/pcmcia/rsrc_iodyn.c
> index 7791375..d0bf350 100644
> --- a/drivers/pcmcia/rsrc_iodyn.c
> +++ b/drivers/pcmcia/rsrc_iodyn.c
> @@ -12,6 +12,7 @@
>   * (C) 1999		David A. Hinds
>   */
>  
> +#include <linux/slab.h>
>  #include <linux/module.h>
>  #include <linux/kernel.h>
>  
> -- 
> 1.6.4.2
> 
