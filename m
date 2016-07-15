From: Andreas Werner <andreas.werner@men.de>
Subject: Re: [PATCH] net: can: Introduce MEN 16Z192-00 CAN controller driver
Date: Fri, 15 Jul 2016 10:02:03 +0200
Message-ID: <20160715080202.GA5183@awelinux>
References: <20160628134412.GA25172@awelinux>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <mkl@pengutronix.de>, <linux-can@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<morbidrsa@gmail.com>, <andy@wernerandy.de>
To: <wg@grandegger.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160628134412.GA25172@awelinux>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
just want to send a ping.

Does anybody have comments on this driver?

Regards
Andy

> This CAN Controller is found on MEN Chameleon FPGAs.
> 
> The driver/device supports the CAN2.0 specification.
> There are 255 RX and 255 Tx buffer within the IP. The
> pointer for the buffer are handled by HW to make the
> access from within the driver as simple as possible.
>
> The driver also supports parameters to configure the
> buffer level interrupt for RX/TX as well as a RX timeout
> interrupt.
> 
> With this configuration options, the driver/device
> provides flexibility for different types of usecases.
> 
> Signed-off-by: Andreas Werner <andreas.werner@men.de>
> ---
>  drivers/net/can/Kconfig        |  10 +
>  drivers/net/can/Makefile       |   1 +
>  drivers/net/can/men_z192_can.c | 990 +++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 1001 insertions(+)
>  create mode 100644 drivers/net/can/men_z192_can.c
