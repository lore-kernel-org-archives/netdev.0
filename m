From: Li Frank-B20596 <B20596@freescale.com>
Subject: RE: [PATCH] net: fec: make local function fec_poll_controller()
 static
Date: Wed, 20 Mar 2013 15:11:13 +0000
Message-ID: <1F990F8245A4214A8CC4BFFBD9F790F9088900EC@039-SN1MPN1-001.039d.mgd.msft.net>
References: <CAPgLHd-ZLKjHdqc_Bm44co+9eTF48TOg9zY8c1jbqeG+jnn3GQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "yongjun_wei@trendmicro.com.cn" <yongjun_wei@trendmicro.com.cn>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>
To: Wei Yongjun <weiyj.lk@gmail.com>,
	"grant.likely@secretlab.ca" <grant.likely@secretlab.ca>,
	"rob.herring@calxeda.com" <rob.herring@calxeda.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	Estevam Fabio-R49496 <r49496@freescale.com>,
	"s.hauer@pengutronix.de" <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe004.messaging.microsoft.com ([213.199.154.207]:32582
	"EHLO am1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757425Ab3CTPLU convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Mar 2013 11:11:20 -0400
In-Reply-To: <CAPgLHd-ZLKjHdqc_Bm44co+9eTF48TOg9zY8c1jbqeG+jnn3GQ@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked.

> -----Original Message-----
> From: Wei Yongjun [mailto:weiyj.lk@gmail.com]
> Sent: Wednesday, March 20, 2013 11:06 PM
> To: grant.likely@secretlab.ca; rob.herring@calxeda.com; davem@davemloft.net;
> Li Frank-B20596; shawn.guo@linaro.org; Estevam Fabio-R49496;
> s.hauer@pengutronix.de
> Cc: yongjun_wei@trendmicro.com.cn; netdev@vger.kernel.org; devicetree-
> discuss@lists.ozlabs.org
> Subject: [PATCH] net: fec: make local function fec_poll_controller() static
> 
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> fec_poll_controller() was not declared. It should be static.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> ---
>  drivers/net/ethernet/freescale/fec.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec.c
> b/drivers/net/ethernet/freescale/fec.c
> index e3f3937..1ece68b 100644
> --- a/drivers/net/ethernet/freescale/fec.c
> +++ b/drivers/net/ethernet/freescale/fec.c
> @@ -1559,7 +1559,7 @@ fec_set_mac_address(struct net_device *ndev, void *p)
>   * Polled functionality used by netconsole and others in non interrupt mode
>   *
>   */
> -void fec_poll_controller(struct net_device *dev)
> +static void fec_poll_controller(struct net_device *dev)
>  {
>  	int i;
>  	struct fec_enet_private *fep = netdev_priv(dev);
> 
> 
