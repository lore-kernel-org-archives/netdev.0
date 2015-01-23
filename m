From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH] net: Linn Ethernet Packet Sniffer driver
Date: Fri, 23 Jan 2015 11:21:37 +0100
Message-ID: <3515756.ch1oRd7PaS@wuerfel>
References: <1422007621-13567-1-git-send-email-stathis.voukelatos@linn.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Stathis Voukelatos <stathis.voukelatos-zgcZaY4qg+21Qrn1Bg8BZw@public.gmane.org>,
	abrestic-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org
To: Stathis Voukelatos <stathisv70-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1422007621-13567-1-git-send-email-stathis.voukelatos-zgcZaY4qg+21Qrn1Bg8BZw@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Friday 23 January 2015 10:07:01 Stathis Voukelatos wrote:
> +- interrupts : sniffer interrupt specifier
> +- clocks : specify the system clock for the peripheral
> +- clock-names : must contain the "sys" entry
> +- fifo-block-words : number of words in one data FIFO entry
> +
> +Example:
> +
> +sniffer@1814a000 {
> +        compatible = "linn,eth-sniffer";
> +        reg = <0x1814a000 0x100>, <0x1814a400 0x400>, <0x1814a800 0x400>;
> +        reg-names = "regs", "tx-ram", "rx-ram";
> +        interrupts = <GIC_SHARED 58 IRQ_TYPE_LEVEL_HIGH>;
> +        interrupt-names = "eth-sniffer-irq";
> +        clocks = <&system_clk>;
> +        clock-names = "sys";
> +        fifo-block-words = <4>;
> 

The example contains an interrupt-names property that is not documented.
If you want to name interrupts, the exact name strings need to
be mandated by the binding. Alternatively just drop the name.
I notice that the driver requests the first interrupt without giving
a name anyway, and the description above suggests that there can
only be one interrupt.

	Arnd
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
