From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net v2 1/2] ARM: dts: imx: name the interrupts for the
 fec ethernet driver
Date: Sat, 14 Oct 2017 20:50:18 +0200
Message-ID: <20171014185018.GD18578@lunn.ch>
References: <20171014020940.32736-1-troy.kisky@boundarydevices.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shawn.guo@linaro.org, fugang.duan@nxp.com, netdev@vger.kernel.org,
        davem@davemloft.net, fabio.estevam@nxp.com, lznuaa@gmail.com
To: Troy Kisky <troy.kisky@boundarydevices.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:45360 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751975AbdJNSuX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 14 Oct 2017 14:50:23 -0400
Content-Disposition: inline
In-Reply-To: <20171014020940.32736-1-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 13, 2017 at 07:09:39PM -0700, Troy Kisky wrote:
> imx7s/imx7d has the ptp interrupt newly added as well.

Hi Troy
 
> For imx7, "int0" is the interrupt for queue 0 and ENET_MII
> "int1" is for queue 1
> "int2" is for queue 2

Thanks for adding this explanation. Please also add it to

Documentation/devicetree/bindings/net/fsl-fec.txt 

>  			fec: ethernet@02188000 {
>  				compatible = "fsl,imx6q-fec";
>  				reg = <0x02188000 0x4000>;
> +				interrupt-names = "int0","ptp";

It is normal to have a space after the ,

   Andrew
