From: Ben Dooks <ben-linux-elnMNo+KYs3YtjvyW6yDsg@public.gmane.org>
Subject: Re: [PATCH 33/37] sound/soc: use .dev.of_node instead of .node in
 struct of_device
Date: Tue, 6 Apr 2010 00:03:01 +0100
Message-ID: <20100405230301.GF32401@fluff.org.uk>
References: <20100311174830.4824.19820.stgit@angua>
 <20100311180649.4824.10368.stgit@angua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org, gregkh-l3A5Bk7waGM@public.gmane.org, benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org, jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org, ben-linux-elnMNo+KYs3YtjvyW6yDsg@public.gmane.org,
	dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, jeremy.kerr-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org,
	James.Bottomley-l3A5Bk7waGM@public.gmane.org, broonie-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org,
	microblaze-uclinux-rVRm/Wmeqae7NGdpmJTKYQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-ide-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org
To: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Return-path: <linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100311180649.4824.10368.stgit@angua>
Sender: linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 11, 2010 at 11:06:50AM -0700, Grant Likely wrote:
> .node is being removed
> 
> Signed-off-by: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
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

This looks like one case where an inline function would have been a
help.


-- 
Ben (ben-elnMNo+KYs3YtjvyW6yDsg@public.gmane.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
