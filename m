From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH RESEND] can: mcp251x: Replace power callbacks with regulator
 API
Date: Tue, 20 Aug 2013 10:46:15 +0200
Message-ID: <52132CD7.50100@pengutronix.de>
References: <1375963227-6468-1-git-send-email-shc_work@mail.ru> <52049C44.6030902@pengutronix.de> <520EDDA8.6050309@gmail.com> <20130817083014.a01144051b158c34ec7dd9d9@mail.ru> <CAN1soZz68ymkj4x5bWTP-6Qc7zVuVotLoT8nYLrdTd3DQHyFbQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="GeksnCwvddiDawgX0HxbwDSwDwkCgrFVP"
Cc: Alexander Shiyan <shc_work@mail.ru>,
	Eric Miao <eric.y.miao@gmail.com>, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, Wolfgang Grandegger <wg@grandegger.com>,
	Russell King <linux@arm.linux.org.uk>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: Haojian Zhuang <haojian.zhuang@gmail.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <CAN1soZz68ymkj4x5bWTP-6Qc7zVuVotLoT8nYLrdTd3DQHyFbQ@mail.gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--GeksnCwvddiDawgX0HxbwDSwDwkCgrFVP
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 08/17/2013 06:37 AM, Haojian Zhuang wrote:
> On Sat, Aug 17, 2013 at 12:30 PM, Alexander Shiyan <shc_work@mail.ru> w=
rote:
>> On Sat, 17 Aug 2013 10:19:20 +0800
>> Haojian Zhuang <haojian.zhuang@gmail.com> wrote:
>>
>>> On 08/09/2013 03:37 PM, Marc Kleine-Budde wrote:
>>>> On 08/08/2013 02:00 PM, Alexander Shiyan wrote:
>>>>> Signed-off-by: Alexander Shiyan <shc_work@mail.ru>
>>>>> ---
>>>>>   arch/arm/mach-pxa/icontrol.c         |  3 --
>>>>>   arch/arm/mach-pxa/zeus.c             | 46 ++++++++++----------
>>>>
>>>> What's pxa's status of DT conversion? Do you (still) accept patches =
to
>>>> board files?
>>>>
>>>> Marc
>>>>
>>>
>>> Since DT conversion isn't finished, I still accept the board files.
>>> But this patch should be split into two parts. One is for pxa, and th=
e
>>> other one is for net.
>>
>> Patch cannot be splitted because this can create hole which break git-=
bisect.
>>
>> In any case, I want to create a v2 with a more detailed description, a=
nd I
>> have a supplementary question for the CAN subsystem maintainers.
>> "Transciever power" is not used by any of the boards, can we remove it=

>> completely? This will greatly simplify driver.
>> Thanks.
>>
>> --
>> Alexander Shiyan <shc_work@mail.ru>
>=20
> If you want to make the patch go through pxa tree, you need to get the =
Ack
> from CAN maintainer.

The current series consists of 3 patches, only the first one touches
"arch/arm/mach-pxa", so I'd like the patches to go via linux-can. Can I
have your Acked-by for the first patch "[PATCH v2 1/3] can: mcp251x:
Replace power callbacks with regulator AP"

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--GeksnCwvddiDawgX0HxbwDSwDwkCgrFVP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlITLNcACgkQjTAFq1RaXHOO5gCfeXjmDzePrJarUr6p3fl5/t8Q
JCEAn3I/ZE3PFHuBzAt3154In4mZZ1SM
=lc3r
-----END PGP SIGNATURE-----

--GeksnCwvddiDawgX0HxbwDSwDwkCgrFVP--
