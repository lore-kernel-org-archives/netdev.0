From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v7 6/8] net: can: c_can: Disable pins when CAN interface
 is down
Date: Thu, 27 Nov 2014 22:19:32 +0100
Message-ID: <54779564.7010309@pengutronix.de>
References: <1415371762-29885-1-git-send-email-rogerq@ti.com>	<1415371762-29885-7-git-send-email-rogerq@ti.com>	<5464CCFF.5010004@ti.com>	<5466225D.2070202@ti.com> <CACRpkdbVXPi7fNjGEzChayQ1KQg8h2R6sm0TNRsVOFJmAT=YMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="Nob98WK4JRpvj27hLKKiPP4bDNp2AElkm"
Cc: wg@grandegger.com, Wolfram Sang <wsa@the-dreams.de>,
	Tony Lindgren <tony@atomide.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	George Cherian <george.cherian@ti.com>,
	Felipe Balbi <balbi@ti.com>, Sekhar Nori <nsekhar@ti.com>,
	Nishanth Menon <nm@ti.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Linux-OMAP <linux-omap@vger.kernel.org>,
	linux-can@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Linus Walleij <linus.walleij@linaro.org>,
	Roger Quadros <rogerq@ti.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <CACRpkdbVXPi7fNjGEzChayQ1KQg8h2R6sm0TNRsVOFJmAT=YMQ@mail.gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Nob98WK4JRpvj27hLKKiPP4bDNp2AElkm
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/27/2014 02:26 PM, Linus Walleij wrote:
> On Fri, Nov 14, 2014 at 4:40 PM, Roger Quadros <rogerq@ti.com> wrote:
>=20
>> DRA7 CAN IP suffers from a problem which causes it to be prevented
>> from fully turning OFF (i.e. stuck in transition) if the module was
>> disabled while there was traffic on the CAN_RX line.
>>
>> To work around this issue we select the SLEEP pin state by default
>> on probe and use the DEFAULT pin state on CAN up and back to the
>> SLEEP pin state on CAN down.
>>
>> Signed-off-by: Roger Quadros <rogerq@ti.com>
>=20
> Reviewed-by: Linus Walleij <linus.walleij@linaro.org>

Thanks, however the patch is already upstream.

>=20
> I see you figured it out all by yourselves :D
>=20
> (Sorry for being absent.)
>=20
>> +#include <linux/pinctrl/consumer.h>
>> +       pinctrl_pm_select_default_state(dev->dev.parent);
>> +       pinctrl_pm_select_sleep_state(dev->dev.parent);
>> +       pinctrl_pm_select_sleep_state(dev->dev.parent);
>=20
> NB: in drivers/base/pinctrl.c:
>=20
> #ifdef CONFIG_PM
>         /*
>          * If power management is enabled, we also look for the optiona=
l
>          * sleep and idle pin states, with semantics as defined in
>          * <linux/pinctrl/pinctrl-state.h>
>          */
>         dev->pins->sleep_state =3D pinctrl_lookup_state(dev->pins->p,
>                                         PINCTRL_STATE_SLEEP);
>=20
> So if these states are necessary for the driver to work, put
> depends on PM or select PM in the Kconfig.

Roger, you can prepare a patch, if needed.

Thanks,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--Nob98WK4JRpvj27hLKKiPP4bDNp2AElkm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUd5VkAAoJECte4hHFiupUY2wP+gK7cXqMZR8Ngqh0Mz4Ktw1y
nb1IR8xoeQDeIZPeH5j7FiqcmrQlxipC8ux32KsSN34XzLa6ptopV+6MaDeaOl4H
//7NIkJrdsc4SVKF54rEycn345F3IpM46MmjrISDApSZswk4pn66wql3BrTLiCEH
EN88x4XA2Am4i8UXBRuGtrRXJ0YFEeWE1ut60Cu9IDdJR32keUnWjGpVAy0fIwJb
IZsd/svOuAHN14lc2dTO0t4jZAVQmcyDC0ePggXGRMs6vL9kmkYUO6DzTMyG30eC
eS69oR4+QvEuoG4PfLksvdAD7kY4vlPCfJBzjM2O+ImWjMrMd7l6LRRwgvdaS3dU
C2i5G6rUi3eBbE4f6XyIwLut5lWQmXW8h30pdClXV0kK5MpfapuGr9+Ix8oB78KP
L31EcN9TdbEQUjwBHi5bm2308xk0AgShR+tK7QnQ/OorjF1A5RL3TGqSPomKrq65
rLj5s96i0Z9DNtQs3z+//DKOx3S1Z/IlxqlH6OCmUZNZEVsPwC+MFivz+j0kgSFK
ZqDWoNhLelfqjguqEIzU6b/b5Uu53tIcZsW5fCVOURGTL/BTLLZAuz2Pn0fSsJEH
jiKhg5ubmEkCIcyeF9tlbRohLyfAyGE6X/fOPevzKbrXIM5hOI4Utrpozwa7cIp+
pUDqpOkG3DkpIzAFXMlk
=YtwN
-----END PGP SIGNATURE-----

--Nob98WK4JRpvj27hLKKiPP4bDNp2AElkm--
