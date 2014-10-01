From: Roger Quadros <rogerq@ti.com>
Subject: Re: [PATCH v2 2/3] net: can: c_can: Add syscon/regmap RAMINIT mechanism
Date: Wed, 1 Oct 2014 13:57:54 +0300
Message-ID: <542BDE32.6030309@ti.com>
References: <20140930144950.GQ1325@katana> <542AC5B2.9040406@pengutronix.de> <20140930152550.GR1325@katana> <542AD483.2020808@pengutronix.de> <542BBF3F.2040803@ti.com> <542BBFBE.90406@pengutronix.de> <542BC42F.2010406@ti.com> <542BD116.4090809@pengutronix.de> <542BD3A7.5060200@ti.com> <542BD6F1.2020900@pengutronix.de> <20141001104317.GB1261@katana>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <wg@grandegger.com>, <tony@atomide.com>, <tglx@linutronix.de>,
	<mugunthanvnm@ti.com>, <george.cherian@ti.com>, <balbi@ti.com>,
	<nsekhar@ti.com>, <nm@ti.com>,
	<sergei.shtylyov@cogentembedded.com>, <linux-omap@vger.kernel.org>,
	<linux-can@vger.kernel.org>, <netdev@vger.kernel.org>
To: Wolfram Sang <wsa@the-dreams.de>,
	Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20141001104317.GB1261@katana>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/01/2014 01:43 PM, Wolfram Sang wrote:
> 
>>> Unfortunately it is 5 ;)
>>> We have display IP related bit in between 3 and 5 :P
>>
>> What on earth were the HW engineers thinking????????????
> 
> "Let's test my RNG on the bit-placement of this register" :)

:D

> 
>> ...if we just have the instance parameter in the syscon phandle, we have
>> to put the mapping into the driver, which makes IMHO no sense, because
>> you have to touch the driver, if there is another SoC with the DCAN core.

My guess is that TI won't come up with a 3rd variant so we won't have to
touch the driver, but you never know for sure.

> 
> ... which would be my preferred solution. I think new SoCs should have
> some kind of:
> 
> 	compatible = "commodore,c64ultra", "bosch,d_can";
> 
> in the DT anyhow to allow for SoC specific quirks/adjustments. And
> custom raminit belongs to that IMO (see the ti routine getting more and
> more specific).
> 

Right. For now we need 2 start/stop definations for the existing TI Socs.

but where to store the raminit start/stop bits? The driver_data currently seems to 
contain the CAN type C_CAN vs D_CAN without containing it in a platform_data structure.

Is it OK to create a new platform_data structure for CAN and put the type and raminit start/stop
bits there?

cheers,
-roger
