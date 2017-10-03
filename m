From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net v1 1/2] ARM: dts: imx: let's name the ptp interrupt
 for the fec ethernet driver
Date: Tue, 3 Oct 2017 02:51:48 +0200
Message-ID: <20171003005148.GA24147@lunn.ch>
References: <20171003000442.31841-1-troy.kisky@boundarydevices.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shawn.guo@linaro.org, fugang.duan@nxp.com, netdev@vger.kernel.org,
        davem@davemloft.net, fabio.estevam@nxp.com, lznuaa@gmail.com
To: Troy Kisky <troy.kisky@boundarydevices.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:36351 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750869AbdJCAvx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Oct 2017 20:51:53 -0400
Content-Disposition: inline
In-Reply-To: <20171003000442.31841-1-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 02, 2017 at 05:04:41PM -0700, Troy Kisky wrote:
> imx7s/imx7d has the ptp interrupt newly added as well.
> This will allow the ptp interrupt to have its own interrupt routine.
> 
> Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
> ---
>  arch/arm/boot/dts/imx6qdl.dtsi | 1 +
>  arch/arm/boot/dts/imx6sx.dtsi  | 2 ++
>  arch/arm/boot/dts/imx6ul.dtsi  | 2 ++
>  arch/arm/boot/dts/imx7d.dtsi   | 4 +++-
>  arch/arm/boot/dts/imx7s.dtsi   | 4 +++-
>  5 files changed, 11 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/arm/boot/dts/imx6qdl.dtsi b/arch/arm/boot/dts/imx6qdl.dtsi
> index 8884b4a3cafb..d848d2bfe8e2 100644
> --- a/arch/arm/boot/dts/imx6qdl.dtsi
> +++ b/arch/arm/boot/dts/imx6qdl.dtsi
> @@ -1017,6 +1017,7 @@
>  			fec: ethernet@02188000 {
>  				compatible = "fsl,imx6q-fec";
>  				reg = <0x02188000 0x4000>;
> +				interrupt-names = "","ptp";

Hi Troy

The "" looks a bit odd. Can you use a name here?

    Andrew
