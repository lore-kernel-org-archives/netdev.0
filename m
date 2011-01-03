From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH] ll_temac: Fix section mismatch from the temac_of_probe
Date: Mon, 3 Jan 2011 10:03:32 -0700
Message-ID: <20110103170332.GB2522@angua.secretlab.ca>
References: <1294050756-31099-1-git-send-email-monstr@monstr.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org, davem@davemloft.net
To: Michal Simek <monstr@monstr.eu>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1294050756-31099-1-git-send-email-monstr@monstr.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 03, 2011 at 11:32:36AM +0100, Michal Simek wrote:
> Replace __init by __devinit.
> 
> Warning message:
> WARNING: vmlinux.o(.data+0xbc14): Section mismatch in reference from the variable
> temac_of_driver to the function .init.text:temac_of_probe()
> The variable temac_of_driver references
> the function __init temac_of_probe()
> If the reference is valid then annotate the
> variable with __init* or __refdata (see linux/init.h) or name the variable:
> *_template, *_timer, *_sht, *_ops, *_probe, *_probe_one, *_console,
> 
> Signed-off-by: Michal Simek <monstr@monstr.eu>

Acked-by: Grant Likely <grant.likely@secretlab.ca>

> ---
>  drivers/net/ll_temac_main.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ll_temac_main.c b/drivers/net/ll_temac_main.c
> index 9f8e702..beb6ed8 100644
> --- a/drivers/net/ll_temac_main.c
> +++ b/drivers/net/ll_temac_main.c
> @@ -952,7 +952,7 @@ static const struct attribute_group temac_attr_group = {
>  	.attrs = temac_device_attrs,
>  };
>  
> -static int __init
> +static int __devinit
>  temac_of_probe(struct platform_device *op, const struct of_device_id *match)
>  {
>  	struct device_node *np;
> -- 
> 1.5.5.6
> 
