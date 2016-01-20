From: Kurt Van Dijck <dev.kurt@vandijck-laurijssen.be>
Subject: Re: [PATCH v2] can: c_can: add xceiver enable/disable support
Date: Wed, 20 Jan 2016 15:11:51 +0100
Message-ID: <20160120141151.GA626@airbook.eia.lan>
References: <1453297443-23279-1-git-send-email-m.grzeschik@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: mkl@pengutronix.de, wg@grandegger.com, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@pengutronix.de
To: Michael Grzeschik <m.grzeschik@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1453297443-23279-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
> index f91b094..0723aeb 100644
> --- a/drivers/net/can/c_can/c_can.c
> +++ b/drivers/net/can/c_can/c_can.c
> @@ -1263,6 +1271,10 @@ int register_c_can_dev(struct net_device *dev)
>  	 */
>  	pinctrl_pm_select_sleep_state(dev->dev.parent);
>  
> +	priv->reg_xceiver = devm_regulator_get(priv->device, "xceiver");

I assume "xceiver" is the shorter name for "transceiver"?
In that case, I suggest changing the devicetree label to "transceiver".
It would become a mess if different drivers use different names.
I see no real benefit for naming it "xceiver". "trx" is even shorter :-)
See also http://www.acronymfinder.com/TRX.html

The internals, like variable names, do not really matter here.

I haven't looked at other driver, yet the argument still stands.

Kind regards,
Kurt
