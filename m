From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH V2 1/4] can: m_can: update to support CAN FD features
Date: Wed, 05 Nov 2014 14:19:22 +0100
Message-ID: <545A23DA.7030303@pengutronix.de>
References: <1415174326-6623-1-git-send-email-b29396@freescale.com> <5459F808.3020903@hartkopp.net> <20141105112639.GB4007@shlinux1.ap.freescale.net> <545A21AD.5040608@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="7bntQfDJfx04FSEBlkoovUnVoC9PeXxHA"
Cc: linux-can@vger.kernel.org, wg@grandegger.com,
	varkabhadram@gmail.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Oliver Hartkopp <socketcan@hartkopp.net>,
	Dong Aisheng <b29396@freescale.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <545A21AD.5040608@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--7bntQfDJfx04FSEBlkoovUnVoC9PeXxHA
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/05/2014 02:10 PM, Oliver Hartkopp wrote:
> On 05.11.2014 12:26, Dong Aisheng wrote:
>> On Wed, Nov 05, 2014 at 11:12:24AM +0100, Oliver Hartkopp wrote:
>>> On 05.11.2014 08:58, Dong Aisheng wrote:
>=20
>=20
>>> Unfortunately No. Here it becomes complicated due to the fact that
>>> the revision 3.0.x does not support per-frame switching for FD/BRS
>>> ...
>>
>> I'm not sure i got your point.
>>  From m_can spec, it allows switch CAN mode by setting CMR bit.
>>
>> Bits 11:10 CMR[1:0]: CAN Mode Request
>> A change of the CAN operation mode is requested by writing to this bit=

>> field. After change to the
>> requested operation mode the bit field is reset to =E2=80=9C00=E2=80=9D=
 and the status
>> flags FDBS and FDO are set
>> accordingly. In case the requested CAN operation mode is not enabled,
>> the value written to CMR is
>> retained until it is overwritten by the next mode change request. In
>> case CME =3D =E2=80=9C01=E2=80=9D/=E2=80=9D10=E2=80=9D/=E2=80=9D11=E2=80=
=9D a
>> change to CAN operation according to ISO 11898-1 is always possible.
>> Default is CAN operation
>> according to ISO11898-1.
>> 00 unchanged
>> 01 Request CAN FD operation
>> 10 Request CAN FD operation with bit rate switching
>> 11 Request CAN operation according ISO11898-1
>>
>> So what's the difference between this function and the per-frame
>> switching
>> you mentioned?
>>
>>>
>>> When (priv->can.ctrlmode & CAN_CTRLMODE_FD) is true this *only*
>>> tells us, that the controller is _capable_ to send either CAN or CAN
>>> FD frames.
>>>
>>> It does not configure the controller into one of these specific
>>> settings!
>>>
>>> Additionally: AFAIK when writing to the CCCR you have to make sure
>>> that there's currently no ongoing transfer.
>>>
>>
>> I don't know about it before.
>> By searching m_can user manual v302 again, i still did not find this
>> limitation. Can you point me if you know where it is?
>>
>> BTW, since we only use one Tx Buffer for transmission currently, so we=

>> should not meet that case that CAN mode is switched during transfer.
>> So the issue you concern may not happen.
>=20
> Yes. You are right. Having a FIFO with a size of 1 will help here :-)

Errrr....sorry...no.

Taking an easy route here but making it x times harder to extend the
driver to make use of the FIFO is not an option.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--7bntQfDJfx04FSEBlkoovUnVoC9PeXxHA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUWiPaAAoJECte4hHFiupUIMYP/0EmlYshc3dRBBcnOxCsp847
mpbIo2UFWv0bWNt8Rl9qZd/eb40RffBSAVwDI3HIRSprknhOud60DweyaUP/U/g+
fGR5h2jkejYXT97czox3UaT482TnSHZTBCTcXwkqCvYxwKAnGyNYzmfBmIiFs7SF
gj0gIA+Z+tY/7jrNAmrAm8D2ETCksiYw7GBjIDz10hYCmJHrDuJ8jDchhyiLkI+V
SLQObJ3vY7VuwccbYIS76MIqebfzphGmtRLImH3yTDIGWgj8UCZcbBxidRpc9UEx
GEEDiV0JZ1doj2XsLFnjoSeG/Qa2dGKFVNGGbYCrR7gwfkCusBgr+JcFtue15DW4
J7hMpmpjaTHyK70H2JVfnv6DZG8wMpvC5qnXxniJ9PbRCbXPo8YGcepmx6aO2jCu
L4FsTaIG7vXQLWGRgsR/NNwLy9CJP+fIWePhIaXhgxn+7I7EP7dG+2OQNY2JKCY+
E1P44eOyymtBvsfCEmc4Tgorzk44RL9BP2Lc3l/eQlFi1d4XH5H33wvwEdsi2cGV
3ARJknAC+w9NI/vUcilPP8RFd68EYbBOqCeqIIrQUKQMfEl/svBABpKqzwlv9kl3
dOM2FIGLaCrwiufJVTwxOYTkVERiZZfiQnAl50Lfh6q53Y/seYUxIpm8UBNyg2Qm
bom5rH/aCAyoKn8sJsZx
=a4Fg
-----END PGP SIGNATURE-----

--7bntQfDJfx04FSEBlkoovUnVoC9PeXxHA--
