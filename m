From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH 11/13] can: at91_can: use endian agnostic IO accessors
Date: Thu, 19 Mar 2015 17:47:26 +0100
Message-ID: <550AFD9E.60801@atmel.com>
References: <1426693992-31163-1-git-send-email-ben.dooks@codethink.co.uk> <1426693992-31163-12-git-send-email-ben.dooks@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-kernel@lists.codethink.co.uk>,
	<linux-arm-kernel@lists.infradead.org>,
	Wolfgang Grandegger <wg@grandegger.com>,
	<netdev@vger.kernel.org>
To: Ben Dooks <ben.dooks@codethink.co.uk>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	<linux-can@vger.kernel.org>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1426693992-31163-12-git-send-email-ben.dooks@codethink.co.uk>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 18/03/2015 16:53, Ben Dooks a =E9crit :
> Change __raw accesors to  endian agnostic versions to allow the drive=
r
> to work properly on big endian systems.
>=20
> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
> --
> CC: Wolfgang Grandegger <wg@grandegger.com>
> CC: Marc Kleine-Budde <mkl@pengutronix.de>
> CC: linux-can@vger.kernel.org
> CC: netdev@vger.kernel.org
> CC: Nicolas Ferre <nicolas.ferre@atmel.com>

Sure!
Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

Thanks, bye.


> ---
>  drivers/net/can/at91_can.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
> index eeb4b8b..f4e40aa 100644
> --- a/drivers/net/can/at91_can.c
> +++ b/drivers/net/can/at91_can.c
> @@ -291,13 +291,13 @@ static inline unsigned int get_tx_echo_mb(const=
 struct at91_priv *priv)
> =20
>  static inline u32 at91_read(const struct at91_priv *priv, enum at91_=
reg reg)
>  {
> -	return __raw_readl(priv->reg_base + reg);
> +	return readl_relaxed(priv->reg_base + reg);
>  }
> =20
>  static inline void at91_write(const struct at91_priv *priv, enum at9=
1_reg reg,
>  		u32 value)
>  {
> -	__raw_writel(value, priv->reg_base + reg);
> +	writel_relaxed(value, priv->reg_base + reg);
>  }
> =20
>  static inline void set_mb_mode_prio(const struct at91_priv *priv,
>=20


--=20
Nicolas Ferre
