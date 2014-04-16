From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH] net: c_can: Add support for D_CAN module RAM Init.
Date: Wed, 16 Apr 2014 23:13:23 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1404162312020.22697@ionos.tec.linutronix.de>
References: <1397672973-3480-1-git-send-email-tthayer@altera.com> <1397672973-3480-2-git-send-email-tthayer@altera.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-can@vger.kernel.org, wg@grandegger.com, mkl@pengutronix.de,
	socketcan@hartkopp.net, anilkumar@ti.com, tthayer.linux@gmail.com,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Thor Thayer <tthayer@altera.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1397672973-3480-2-git-send-email-tthayer@altera.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Wed, 16 Apr 2014, tthayer@altera.com wrote:

> From: Thor Thayer <tthayer@altera.com>
> 
> The D_CAN driver was written to support the TI D_CAN implementation
> which placed the D_CAN RAM reset in a separate register. In the
> standard D_CAN module the RAM Init is in the D_CAN module so
> handle the RAM Init differently.
> +		if (!res) {
> +			priv->raminit = c_can_hw_raminit;
> +			priv->raminit_type_flag = 0;

Can we please make that raminit_type and use proper constants?

Thanks,

	tglx
