From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sched: enable CAN Identifier to be build into
 kernel
Date: Sun, 25 Nov 2012 16:06:44 -0500 (EST)
Message-ID: <20121125.160644.398080366230597668.davem@davemloft.net>
References: <1353667497-25676-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org
To: mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1353667497-25676-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Fri, 23 Nov 2012 11:44:57 +0100

> This patch makes it possible to build the CAN Identifier into the kernel, even
> if the CAN support is build as a module.
> 
> Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>

Applied to net-next, thanks.

> is there a nicer solution to this problem? Or remove the "&& CAN" at all?

I don't see how enabling this with CAN disabled could be
useful, so better to have the dependency there.
