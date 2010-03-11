From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: Re: [PATCH 33/37] sound/soc: use .dev.of_node instead of .node in
 struct of_device
Date: Thu, 11 Mar 2010 19:34:58 +0000
Message-ID: <20100311193458.GA13289@opensource.wolfsonmicro.com>
References: <20100311174830.4824.19820.stgit@angua>
 <20100311180649.4824.10368.stgit@angua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: monstr@monstr.eu, gregkh@suse.de, benh@kernel.crashing.org,
	akpm@linux-foundation.org, davem@davemloft.net,
	sfr@canb.auug.org.au, jgarzik@pobox.com, ben-linux@fluff.org,
	dwmw2@infradead.org, jeremy.kerr@canonical.com,
	James.Bottomley@suse.de, microblaze-uclinux@itee.uq.edu.au,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	sparclinux@vger.kernel.org, linux-ide@vger.kernel.org,
	netdev@vger.kernel.org, linux-i2c@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org, linux-scsi@vger.kernel.org,
	alsa-devel@alsa-project.org, timur@freescale.com,
	lrg@slimlogic.co.uk
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <linux-ide-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100311180649.4824.10368.stgit@angua>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 11, 2010 at 11:06:50AM -0700, Grant Likely wrote:
> .node is being removed
> 
> Signed-off-by: Grant Likely <grant.likely@secretlab.ca>

Acked-by: Mark Brown <broonie@opensource.wolfsonmicro.com>

but please ensure that Liam and especially Timur also check this (both
CCed).

For enormous patch serieses like this it's really nice if you can ensure
that each person is only CCed on the patches that they need to review.
Much less stuff in the inbox.

> ---
> 
>  sound/soc/fsl/mpc8610_hpcd.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/sound/soc/fsl/mpc8610_hpcd.c b/sound/soc/fsl/mpc8610_hpcd.c
> index ef67d1c..d7e1b9a 100644
> --- a/sound/soc/fsl/mpc8610_hpcd.c
> +++ b/sound/soc/fsl/mpc8610_hpcd.c
> @@ -202,7 +202,7 @@ static struct snd_soc_ops mpc8610_hpcd_ops = {
>  static int mpc8610_hpcd_probe(struct of_device *ofdev,
>  	const struct of_device_id *match)
>  {
> -	struct device_node *np = ofdev->node;
> +	struct device_node *np = ofdev->dev.of_node;
>  	struct device_node *codec_np = NULL;
>  	struct device_node *guts_np = NULL;
>  	struct device_node *dma_np = NULL;
> 
