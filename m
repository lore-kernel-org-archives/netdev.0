From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] rcar_can: add device tree support
Date: Thu, 03 Jul 2014 00:26:07 +0400
Message-ID: <53B46ADF.9070602@cogentembedded.com>
References: <201407020227.04235.sergei.shtylyov@cogentembedded.com> <53B33B45.1060205@pengutronix.de> <20140702101437.GC14665@leverpostej>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"wg@grandegger.com" <wg@grandegger.com>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	Pawel Moll <Pawel.Moll@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	"galak@codeaurora.org" <galak@codeaurora.org>,
	"grant.likely@linaro.org" <grant.likely@linaro.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>,
	"vksavl@gmail.com" <vksavl@gmail.com>,
	"rdunlap@infradead.org" <rdunlap@infradead.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>
To: Mark Rutland <mark.rutland@arm.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20140702101437.GC14665@leverpostej>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 07/02/2014 02:14 PM, Mark Rutland wrote:

>>> Add support of the device tree probing for the Renesas R-Car CAN controllers
>>> documenting the device tree bindings as necessary.

[...]

>>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

[...]

>>> Index: net-next/Documentation/devicetree/bindings/net/can/rcar_can.txt
>>> ===================================================================
>>> --- /dev/null
>>> +++ net-next/Documentation/devicetree/bindings/net/can/rcar_can.txt
>>> @@ -0,0 +1,40 @@
[...]

>>> +- reg: physical base address and size of the R-Car CAN register map.
>>> +- interrupts: interrupt specifier for the sole interrupt.
>>> +- clocks: phandle and clock specifier for the R-Car CAN clock input.
>>> +- pinctrl-0: pin control group to be used for this controller.
>>> +- pinctrl-names: must be "default".
>>> +
>>> +Optional properties:
>>> +- clock-select: R-Car CAN Clock Source Select. Valid values are:
>>> +		<0x0> (default) : Peripheral clock (clkp1)
>>> +		<0x1> : Peripheral clock (clkp2)
>>> +		<0x3> : Externally input clock

> What's this for, and how does this interact with the single clock listed
> above?

    That's supposed to select a source for the CAN bus clock. Looking back at 
the driver, it seems to actually only support the value of 0. That's something 
we haven't given enough attention to clearly... :-/

> THanks,
> Mark.

WBR, Sergei

