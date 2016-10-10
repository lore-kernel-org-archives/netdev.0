From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH 4/4] gpio: ptxpmb-ext-cpld: Document bindings of PTXPMB
 extended CPLD
Date: Mon, 10 Oct 2016 15:19:36 -0500
Message-ID: <20161010201936.GB32418@rob-hp-laptop>
References: <1475853574-22339-1-git-send-email-pantelis.antoniou@konsulko.com>
 <1475853574-22339-5-git-send-email-pantelis.antoniou@konsulko.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lee Jones <lee.jones@linaro.org>,
        Linus Walleij <linus.walleij@linaro.org>,
        Alexandre Courbot <gnurou@gmail.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Frank Rowand <frowand.list@gmail.com>,
        Georgi Vlaev <gvlaev@juniper.net>,
        Guenter Roeck <linux@roeck-us.net>,
        JawaharBalaji Thirumalaisamy <jawaharb@juniper.net>,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-gpio@vger.kernel.org, linux-i2c@vger.kernel.org,
        linux-mtd@lists.infradead.org, linux-watchdog@vger.kernel.org,
        netdev@vger.kernel.org
To: Pantelis Antoniou <pantelis.antoniou@konsulko.com>
Return-path: <linux-gpio-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1475853574-22339-5-git-send-email-pantelis.antoniou@konsulko.com>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 07, 2016 at 06:19:34PM +0300, Pantelis Antoniou wrote:
> From: Georgi Vlaev <gvlaev@juniper.net>
> 
> Add device tree bindings document for the GPIO driver of
> Juniper's PTXPMB extended CPLD.
> 
> Signed-off-by: Georgi Vlaev <gvlaev@juniper.net>
> [Ported from Juniper kernel]
> Signed-off-by: Pantelis Antoniou <pantelis.antoniou@konsulko.com>
> ---
>  .../bindings/gpio/jnx,gpio-ptxpmb-ext-cpld.txt     | 36 ++++++++++++++++++++++
>  1 file changed, 36 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/gpio/jnx,gpio-ptxpmb-ext-cpld.txt
> 
> diff --git a/Documentation/devicetree/bindings/gpio/jnx,gpio-ptxpmb-ext-cpld.txt b/Documentation/devicetree/bindings/gpio/jnx,gpio-ptxpmb-ext-cpld.txt
> new file mode 100644
> index 0000000..87f01b9
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/gpio/jnx,gpio-ptxpmb-ext-cpld.txt
> @@ -0,0 +1,36 @@
> +Juniper PTXPMB extended CPLD GPIO block
> +
> +Required properties:
> +
> +- compatible:
> +    Must be "jnx,gpio-ptxpmb-ext-cpld"

Generally, '-gpio' would be last.

> +
> +- #gpio-cells:
> +    Should be <2>.  The first cell is the pin number (within the controller's
> +    pin space), and the second is used for the following flags:
> +	bit[0]: direction (0 = out, 1 = in)
> +	bit[1]: init high
> +	bit[2]: active low

Same comment as all the other gpio bindings...

> +
> +- gpio-controller:
> +    Specifies that the node is a GPIO controller.
> +
> +- interrupt-controller:
> +    Specifies that the node is an interrupt controller.
> +
> +Optional properties:
> +
> +- reg:
> +    Address and length of the register set for the device. Usually supplied
> +    by the parent MFD device.

Make it required.

> +
> +
> +Example:
> +
> +gpio_ext_cpld: cpld-ext-gpio {
> +	compatible = "jnx,gpio-ptxpmb-ext-cpld";
> +	#gpio-cells = <2>;
> +	#interrupt-cells = <2>;
> +	gpio-controller;
> +	interrupt-controller;
> +};
> -- 
> 1.9.1
> 
