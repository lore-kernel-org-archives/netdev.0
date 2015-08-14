From: Duan Andy <fugang.duan@freescale.com>
Subject: RE: [PATCH 1/1] Revert "net: fec: Ensure clocks are enabled while
 using mdio bus"
Date: Fri, 14 Aug 2015 07:03:53 +0000
Message-ID: <CY1PR0301MB1225D2FE7894688AC2433A0BF57C0@CY1PR0301MB1225.namprd03.prod.outlook.com>
References: <1439531254-13128-1-git-send-email-peter.chen@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Peter Chen <Peter.Chen@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	Fabio Estevam <Fabio.Estevam@freescale.com>,
	"tyler.baker@linaro.org" <tyler.baker@linaro.org>,
	Lucas Stach <l.stach@pengutronix.de>,
	Andrew Lunn <andrew@lunn.ch>
To: Peter Chen <Peter.Chen@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0119.outbound.protection.outlook.com ([207.46.100.119]:18249
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751332AbbHNHSt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 03:18:49 -0400
In-Reply-To: <1439531254-13128-1-git-send-email-peter.chen@freescale.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Chen <peter.chen@freescale.com> Sent: Friday, August 14, 2015 1:48 PM
> To: davem@davemloft.net
> Cc: Chen Peter-B29397; netdev@vger.kernel.org; Duan Fugang-B38611;
> shawn.guo@linaro.org; Estevam Fabio-R49496; tyler.baker@linaro.org; Lucas
> Stach; Andrew Lunn
> Subject: [PATCH 1/1] Revert "net: fec: Ensure clocks are enabled while
> using mdio bus"
> 
> It causes the i.mx6sx sdb board hang when using nfsroot during boots up
> at v4.2-rc6.
> 
> This reverts commit 8fff755e9f8d0f70a595e79f248695ce6aef5cc3.
> 
> Cc: netdev@vger.kernel.org
> Cc: Fugang Duan <B38611@freescale.com>
> Cc: shawn.guo@linaro.org
> Cc: fabio.estevam@freescale.com
> Cc: tyler.baker@linaro.org
> Cc: Lucas Stach <l.stach@pengutronix.de>
> Cc: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Peter Chen <peter.chen@freescale.com>
> ---
> 
> According to Fugang Duan, the i.mx series has different clock control
> sequence among SoCs, this patch may only consider certain SoCs.
> 
>  drivers/net/ethernet/freescale/fec_main.c | 89 +++++--------------------
> ------
>  1 file changed, 13 insertions(+), 76 deletions(-)
> 

I suggest to revert the patch. The current patch doesn't consider i.MX6sx/i.MX7d... chips.
As somebody/customer's requirement that want to use MDIO bus is independent of MAC itself, I will submit one mdio driver to separate MDIO bus and MAC driver.

Regards,
Andy
