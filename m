From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/fec: gasket needs to be enabled for some i.mx
Date: Thu, 07 Jul 2011 04:12:57 -0700 (PDT)
Message-ID: <20110707.041257.670268148869400054.davem@davemloft.net>
References: <20110630161935.GA7977@S2100-06.ap.freescale.net>
	<1309515082-7386-1-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, s.hauer@pengutronix.de,
	troy.kisky@boundarydevices.com, u.kleine-koenig@pengutronix.de,
	linux-arm-kernel@lists.infradead.org, LW@KARO-electronics.de
To: shawn.guo@linaro.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1309515082-7386-1-git-send-email-shawn.guo@linaro.org>
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

From: Shawn Guo <shawn.guo@linaro.org>
Date: Fri,  1 Jul 2011 18:11:22 +0800

> On the recent i.mx (mx25/50/53), there is a gasket inside fec
> controller which needs to be enabled no matter phy works in MII
> or RMII mode.
> 
> The current code enables the gasket only when phy interface is RMII.
> It's broken when the driver works with a MII phy.  The patch uses
> platform_device_id to distinguish the SoCs that have the gasket and
> enables it on these SoCs for both MII and RMII mode.
> 
> Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
> Signed-off-by: Shawn Guo <shawn.guo@linaro.org>

Acked-by: David S. Miller <davem@davemloft.net>
