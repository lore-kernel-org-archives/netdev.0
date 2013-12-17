From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: [PATCH] drivers: ssb: Remove unused function
 ssb_sdio_func_to_bus() in main.c
Date: Tue, 17 Dec 2013 08:33:47 -0800
Message-ID: <20131217163347.GB737@leaf>
References: <20131217121314.GA27839@rashika>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, Michael Buesch <m@bues.ch>,
	netdev@vger.kernel.org
To: Rashika Kheria <rashika.kheria@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131217121314.GA27839@rashika>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 17, 2013 at 05:43:14PM +0530, Rashika Kheria wrote:
> Remove unused function ssb_sdio_func_to_bus() in main.c.
>=20
> This eliminates the following warning in main.c:
> drivers/ssb/main.c:94:17: warning: no previous prototype for =E2=80=98=
ssb_sdio_func_to_bus=E2=80=99 [-Wmissing-prototypes]
>=20
> Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>

Reviewed-by: Josh Triplett <josh@joshtriplett.org>

>  drivers/ssb/main.c |   19 -------------------
>  1 file changed, 19 deletions(-)
>=20
> diff --git a/drivers/ssb/main.c b/drivers/ssb/main.c
> index 32a811d..8138952 100644
> --- a/drivers/ssb/main.c
> +++ b/drivers/ssb/main.c
> @@ -90,25 +90,6 @@ found:
>  }
>  #endif /* CONFIG_SSB_PCMCIAHOST */
> =20
> -#ifdef CONFIG_SSB_SDIOHOST
> -struct ssb_bus *ssb_sdio_func_to_bus(struct sdio_func *func)
> -{
> -	struct ssb_bus *bus;
> -
> -	ssb_buses_lock();
> -	list_for_each_entry(bus, &buses, list) {
> -		if (bus->bustype =3D=3D SSB_BUSTYPE_SDIO &&
> -		    bus->host_sdio =3D=3D func)
> -			goto found;
> -	}
> -	bus =3D NULL;
> -found:
> -	ssb_buses_unlock();
> -
> -	return bus;
> -}
> -#endif /* CONFIG_SSB_SDIOHOST */
> -
>  int ssb_for_each_bus_call(unsigned long data,
>  			  int (*func)(struct ssb_bus *bus, unsigned long data))
>  {
> --=20
> 1.7.9.5
>=20
