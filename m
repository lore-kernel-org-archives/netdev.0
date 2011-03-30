From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phylib: phy_attach_direct: phy_init_hw can fail, add
 cleanup
Date: Wed, 30 Mar 2011 02:31:50 -0700 (PDT)
Message-ID: <20110330.023150.58429467.davem@davemloft.net>
References: <1301360048-14095-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev@vger.kernel.org, kernel@pengutronix.de
To: mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1301360048-14095-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Tue, 29 Mar 2011 02:54:08 +0200

> The function phy_attach_direct attaches the phy and calls phy_init_hw.
> phy_init_hw can fail, but the phy is still marked as attached. Successive
> calls to phy_attach_direct will fail because the phy is busy.
 ...
> This patch adds phy_detach to clean up if phy_init_hw fails.
> 
> Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>

Applied, thank you.
