From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] can: c_can_pci: limit compilation to archs with clock
 support
Date: Wed, 20 Jun 2012 02:54:52 -0700 (PDT)
Message-ID: <20120620.025452.2203668280120884694.davem@davemloft.net>
References: <1340185688-9454-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	federico.vaga@gmail.com
To: mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1340185688-9454-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Wed, 20 Jun 2012 11:48:08 +0200

> In commit:
> 
>   5b92da0 c_can_pci: generic module for C_CAN/D_CAN on PCI
> 
> the c_can_pci driver has been added. It uses clk_*() functions
> unconditionally, resulting in a link error on archs without
> clock support. This patch adds a "depends on HAVE_CLK" to the
> Kconfig symbol.

This is an unreasonable change and I just explained why in my email to
Frederico, did you not see it?

He says that this driver was only tested on an architecture that
currently doesn't even have clock support in any existing tree, and
therefore completely relies upon local changes they have to add clock
support to that platform.

Which means you're change is restricting compilation of this driver to
platforms the driver was never, ever, tested on.

Can you see what a complete joke this is?
