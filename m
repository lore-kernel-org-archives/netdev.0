From: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Subject: Re: [PATCH 0/3] Add basic device support for imx51 babbage
Date: Sat, 18 Jun 2011 10:29:27 -0600
Message-ID: <20110618162927.GM8195@ponder.secretlab.ca>
References: <1308410354-21387-1-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, patches-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org
To: Shawn Guo <shawn.guo-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1308410354-21387-1-git-send-email-shawn.guo-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 18, 2011 at 11:19:11PM +0800, Shawn Guo wrote:
> This patch set adds the basic device tree support for imx51 babbage
> board.  With uart and fec dt support added, the dt kernel can boot
> into console with nfs root on babbage, so that we get a good base
> to start playing dt and converting further drivers to use dt on
> imx51.
> 
> It creates the platform imx51-dt for using the device tree, and
> leaves existing board support files alone, so nothing should be
> broken.  The plan is to add stuff step by step into imx51-dt to
> get it support every existing imx51 boards, and then remove the
> existing board files.
> 
> It works against Linus tree plus the dt infrastructure patches
> posted by Grant Likely as part of the following series.
> 
>   [RFC PATCH 00/11] Full device tree support for ARM Versatile
> 
> Comments are appreciated.
> 
> Shawn Guo (3):
>       serial/imx: add device tree support
>       net/fec: add device tree support
>       ARM: mx5: add basic device tree support for imx51 babbage

Good work!  Other than minor comments, this series looks awesome.

g.

> 
>  Documentation/devicetree/bindings/net/fsl-fec.txt  |   14 +++
>  .../bindings/tty/serial/fsl-imx-uart.txt           |   21 +++++
>  arch/arm/boot/dts/imx51-babbage.dts                |   89 ++++++++++++++++++++
>  arch/arm/mach-mx5/Kconfig                          |    8 ++
>  arch/arm/mach-mx5/Makefile                         |    1 +
>  arch/arm/mach-mx5/imx51-dt.c                       |   70 +++++++++++++++
>  drivers/net/fec.c                                  |   28 ++++++
>  drivers/tty/serial/imx.c                           |   81 ++++++++++++++++--
>  8 files changed, 302 insertions(+), 10 deletions(-)
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
