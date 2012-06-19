From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: can-next 2012-06-19
Date: Tue, 19 Jun 2012 15:01:08 -0700 (PDT)
Message-ID: <20120619.150108.62974762508117546.davem@davemloft.net>
References: <4FE0DAB4.6080400@pengutronix.de>
	<20120619.144845.390201286413906004.davem@davemloft.net>
	<20120619.145907.521642979191972656.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org
To: mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20120619.145907.521642979191972656.davem@davemloft.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Tue, 19 Jun 2012 14:59:07 -0700 (PDT)

> From: David Miller <davem@davemloft.net>
> Date: Tue, 19 Jun 2012 14:48:45 -0700 (PDT)
> 
>> From: Marc Kleine-Budde <mkl@pengutronix.de>
>> Date: Tue, 19 Jun 2012 22:01:56 +0200
>> 
>>> here is our second pull request for net-next. In this series Federico
>>> Vaga adds a pci driver for c_can/d_can hardware using the existing
>>> generic c_can driver. The remaining 6 patches are by Oliver Hartkopp.
>>> He adds CANFD support to the CAN stack while keeping binary
>>> compatibility for existing applications. CANFD is an extension to the
>>> existing CAN standard, it allows longer CAN frames and/or higher data
>>> rates. There's no real hardware available yet, but this series adds
>>> CANFD support to the vcan driver.
>> 
>> Pulled, thanks.
> 
> I have to unpull, the new driver results in undefined symbols.
> 
> ERROR: "clk_get_rate" [drivers/net/can/c_can/c_can_pci.ko] undefined!
> ERROR: "clk_get" [drivers/net/can/c_can/c_can_pci.ko] undefined!
> ERROR: "clk_put" [drivers/net/can/c_can/c_can_pci.ko] undefined!

Actually I can't un-pull since I already pushed it out to my
tree.

Send me a fix for this bug, fast.

Thanks.
