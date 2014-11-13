From: Roger Quadros <rogerq@ti.com>
Subject: Re: [PATCH v4 4/8] net: can: c_can: Add syscon/regmap RAMINIT mechanism
Date: Thu, 13 Nov 2014 14:09:10 +0200
Message-ID: <54649F66.8090305@ti.com>
References: <1415371762-29885-1-git-send-email-rogerq@ti.com> <1415371762-29885-5-git-send-email-rogerq@ti.com> <54649153.409@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wsa@the-dreams.de>, <tony@atomide.com>, <tglx@linutronix.de>,
	<mugunthanvnm@ti.com>, <george.cherian@ti.com>, <balbi@ti.com>,
	<nsekhar@ti.com>, <nm@ti.com>,
	<sergei.shtylyov@cogentembedded.com>, <linux-omap@vger.kernel.org>,
	<linux-can@vger.kernel.org>, <netdev@vger.kernel.org>
To: Marc Kleine-Budde <mkl@pengutronix.de>, <wg@grandegger.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <54649153.409@pengutronix.de>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/13/2014 01:09 PM, Marc Kleine-Budde wrote:
> On 11/07/2014 03:49 PM, Roger Quadros wrote:
>> Some TI SoCs like DRA7 have a RAMINIT register specification
>> different from the other AMxx SoCs and as expected by the
>> existing driver.
>>
>> To add more insanity, this register is shared with other
>> IPs like DSS, PCIe and PWM.
>>
>> Provides a more generic mechanism to specify the RAMINIT
>> register location and START/DONE bit position and use the
>> syscon/regmap framework to access the register.
> 
> What about the existing device trees that don't have the syscon-raminit
> phandle? We can either keep the existing init routines or create regmap
> in the platform driver an use the new ones.

There is only one user
arch/arm/boot/dts/am33xx.dtsi

The can nodes are disabled there and no other board file is enabling that node.
So there is no breakage as such and not worth the hassle to maintain the old routine.

I will be sending the corresponding dts changes today which Tony will take as we don't see
any DT binding changes.

cheers,
-roger
