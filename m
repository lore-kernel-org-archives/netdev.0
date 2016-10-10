From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH 2/4] mfd: ptxpmb-ext-cpld: Add documentation for PTXPMB
 extended CPLD
Date: Mon, 10 Oct 2016 15:10:31 -0500
Message-ID: <20161010201031.GA31318@rob-hp-laptop>
References: <1475853574-22339-1-git-send-email-pantelis.antoniou@konsulko.com>
 <1475853574-22339-3-git-send-email-pantelis.antoniou@konsulko.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, Alexandre Courbot <gnurou@gmail.com>,
 linux-watchdog@vger.kernel.org, devicetree@vger.kernel.org,
 Frank Rowand <frowand.list@gmail.com>,
 Linus Walleij <linus.walleij@linaro.org>, linux-kernel@vger.kernel.org,
 JawaharBalaji Thirumalaisamy <jawaharb@juniper.net>,
 linux-gpio@vger.kernel.org, linux-mtd@lists.infradead.org,
 linux-i2c@vger.kernel.org, netdev@vger.kernel.org,
 Georgi Vlaev <gvlaev@juniper.net>, Lee Jones <lee.jones@linaro.org>,
 Guenter Roeck <linux@roeck-us.net>
To: Pantelis Antoniou <pantelis.antoniou@konsulko.com>
Return-path: <linux-mtd-bounces+gldm-linux-mtd-36=gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1475853574-22339-3-git-send-email-pantelis.antoniou@konsulko.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mtd>,
 <mailto:linux-mtd-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mtd/>
List-Post: <mailto:linux-mtd@lists.infradead.org>
List-Help: <mailto:linux-mtd-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mtd>,
 <mailto:linux-mtd-request@lists.infradead.org?subject=subscribe>
Sender: "linux-mtd" <linux-mtd-bounces@lists.infradead.org>
Errors-To: linux-mtd-bounces+gldm-linux-mtd-36=gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 07, 2016 at 06:19:32PM +0300, Pantelis Antoniou wrote:
> From: Georgi Vlaev <gvlaev@juniper.net>
> 
> Add DT bindings document for the PTXPMB extended CPLD device.
> 
> Signed-off-by: Georgi Vlaev <gvlaev@juniper.net>
> [Ported from Juniper kernel]
> Signed-off-by: Pantelis Antoniou <pantelis.antoniou@konsulko.com>
> ---
>  .../bindings/mfd/jnx-ptxpmb-ext-cpld.txt           | 35 ++++++++++++++++++++++
>  1 file changed, 35 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/mfd/jnx-ptxpmb-ext-cpld.txt
> 
> diff --git a/Documentation/devicetree/bindings/mfd/jnx-ptxpmb-ext-cpld.txt b/Documentation/devicetree/bindings/mfd/jnx-ptxpmb-ext-cpld.txt
> new file mode 100644
> index 0000000..098a548a
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/mfd/jnx-ptxpmb-ext-cpld.txt
> @@ -0,0 +1,35 @@
> +* Device tree bindings for Juniper's PTXPMB Extended CPLD FPGA MFD driver
> +
> +The device supports a gpio block which is described in the
> +jnx-gpio-ptxpmb-ext-cpld document.
> +
> +Required properties:
> +
> +- compatible:		"jnx,ptxpmb-ext-cpld"
> +
> +- reg:			contains offset/length value for device state control
> +			registers space.
> +
> +Optional properties:
> +
> +- interrupts:		The interrupt line(s) the /IRQ signal(s) for the device is
> +			connected to.
> +
> +- interrupt-parent:	The parent interrupt controller.
> +
> +Example:
> +
> +ext-cpld@1,0 {
> +	compatible = "jnx,ptxpmb-ext-cpld";
> +	reg = <0x1 0 0x1000>;

What's the bus type here? Unit address is probably wrong.

> +	interrupt-parent = <&mpic>;
> +	interrupts = <7 2>, <8 2>;
> +
> +	gpio_ext_cpld: cpld-ext-gpio {
> +		compatible = "jnx,gpio-ptxpmb-ext-cpld";
> +		#gpio-cells = <2>;
> +		#interrupt-cells = <2>;
> +		gpio-controller;
> +		interrupt-controller;
> +	};
> +};
> -- 
> 1.9.1
> 

______________________________________________________
Linux MTD discussion mailing list
http://lists.infradead.org/mailman/listinfo/linux-mtd/
