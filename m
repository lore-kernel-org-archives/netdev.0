From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] can: c_can_pci: fix compilation on non HAVE_CLK
 archs
Date: Wed, 20 Jun 2012 13:56:08 -0700 (PDT)
Message-ID: <20120620.135608.1188854620320486272.davem@davemloft.net>
References: <1340208266-22098-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	federico.vaga@gmail.com
To: mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1340208266-22098-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Wed, 20 Jun 2012 18:04:26 +0200

> In commit:
> 
>   5b92da0 c_can_pci: generic module for C_CAN/D_CAN on PCI
> 
> the c_can_pci driver has been added. It uses clk_*() functions
> resulting in a link error on archs without clock support. This
> patch removed these clk_() functions as these parts of the driver
> are not tested.
> 
> Cc: Federico Vaga <federico.vaga@gmail.com>
> Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>

Applied.
