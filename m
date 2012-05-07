From: Dong Aisheng <aisheng.dong@freescale.com>
Subject: Re: [PATCH RESEND 0/5] Adopt pinctrl support for a few outstanding
 imx drivers
Date: Mon, 7 May 2012 14:50:02 +0800
Message-ID: <20120507065001.GA23607@shlinux2.ap.freescale.net>
References: <1336352040-28447-1-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <linux-arm-kernel@lists.infradead.org>,
	Arnd Bergmann <arnd@arndb.de>, <netdev@vger.kernel.org>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Wolfram Sang <w.sang@pengutronix.de>,
	<linux-can@vger.kernel.org>,
	Grant Likely <grant.likely@secretlab.ca>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	<linux-i2c@vger.kernel.org>, <linux-serial@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Olof Johansson <olof@lixom.net>,
	<spi-devel-general@lists.sourceforge.net>,
	Dong Aisheng <dong.aisheng@linaro.org>,
	"David S. Miller" <davem@davemloft.net>
To: Shawn Guo <shawn.guo@linaro.org>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1336352040-28447-1-git-send-email-shawn.guo@linaro.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 07, 2012 at 08:53:55AM +0800, Shawn Guo wrote:
> With patch 5b3aa5f (pinctrl: add pinctrl_provide_dummies interface for
> platforms to use) applied on pinctrl tree, and patch "ARM: imx: enable
> pinctrl dummy states" [1] being there, we are ready to adopt pinctrl
> API for imx drivers.  So let's start from a few outstanding ones.
> 
> I would expect to ask Arnd and Olof to pull pinctrl tree into arm-soc
> as a dependency and then have series [1] and this patch set go through
> arm-soc tree to ease the merge process.
> 
Shouldn't we add the pinctrl states in dts file at the same time
with this patch series or using another separate patch to add them
before this series to avoid breaking the exist mx6q platforms?

> Resend to have subsystem lists Cc-ed.
> 
> Regards,
> Shawn
> 
> [1] http://thread.gmane.org/gmane.linux.kernel.mmc/14180
> 
> Shawn Guo (5):
>   tty: serial: imx: adopt pinctrl support
...

>   net: fec: adopt pinctrl support
>   can: flexcan: adopt pinctrl support
This two also depends on another patch you sent.
[PATCH RESEND 1/9] ARM: mxs: enable pinctrl dummy states
http://www.spinics.net/lists/arm-kernel/msg173341.html

Maybe you can put this two in the mxs convert series to avoid breaking
mxs platforms.
[PATCH 0/9] Enable pinctrl support for mach-mxs
http://www.spinics.net/lists/arm-kernel/msg173312.html

Regards
Dong Aisheng

>   i2c: imx: adopt pinctrl support
>   spi/imx: adopt pinctrl support
> 
>  drivers/i2c/busses/i2c-imx.c         |    8 ++++++++
>  drivers/net/can/flexcan.c            |    6 ++++++
>  drivers/net/ethernet/freescale/fec.c |    9 +++++++++
>  drivers/spi/spi-imx.c                |    8 ++++++++
>  drivers/tty/serial/imx.c             |    8 ++++++++
>  5 files changed, 39 insertions(+), 0 deletions(-)
> 
> -- 
> 1.7.5.4
> 
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
> 

