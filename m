From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fec: use interrupt for MDIO completion indication
Date: Thu, 22 Jul 2010 14:12:45 -0700 (PDT)
Message-ID: <20100722.141245.165337920.davem@davemloft.net>
References: <4C3E812C.10303@canonical.com>
	<20100715040956.GA7690@jasper.tkos.co.il>
	<20100721125113.GA2651@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: baruch@tkos.co.il, netdev@vger.kernel.org, bryan.wu@canonical.com,
	kernel@pengutronix.de, gerg@uclinux.org,
	linux-arm-kernel@lists.infradead.org
To: w.sang@pengutronix.de
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20100721125113.GA2651@pengutronix.de>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Wolfram Sang <w.sang@pengutronix.de>
Date: Wed, 21 Jul 2010 14:51:13 +0200

> From: Wolfram Sang <w.sang@pengutronix.de>
> Subject: [PATCH] net/fec: restore interrupt mask after software-reset in fec_stop()
> 
> After the change from mdio polling to irq, it became necessary to
> restore the interrupt mask after resetting the chip in fec_stop().
> Otherwise, with all irqs disabled, no communication with the PHY will be
> possible after e.g. un-/replugging the cable and the device gets
> stalled.
> 
> Signed-off-by: Wolfram Sang <w.sang@pengutronix.de>

Applied.
