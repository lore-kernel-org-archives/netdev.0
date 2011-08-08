From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [RFC 4/4] [powerpc] Implement a p1010rdb clock source.
Date: Mon, 08 Aug 2011 11:32:49 +0200
Message-ID: <4E3FAD41.1030404@pengutronix.de>
References: <1312603504-30282-1-git-send-email-holt@sgi.com>
	<1312603504-30282-5-git-send-email-holt@sgi.com>
	<4E3D4875.30707@pengutronix.de>
	<39414D86-7822-4B92-B005-351890A2A167@kernel.crashing.org>
	<20110806205010.GQ4926@sgi.com>
	<3C4B6145-5C75-4A3C-B504-DA32E0D2EC8A@kernel.crashing.org>
	<4E3FA301.4050005@grandegger.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6430307093957029200=="
Cc: Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	"linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org Development" <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4E3FA301.4050005-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--===============6430307093957029200==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig1D62CFCFD655DC236D061506"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig1D62CFCFD655DC236D061506
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 08/08/2011 10:49 AM, Wolfgang Grandegger wrote:
> On 08/06/2011 10:59 PM, Kumar Gala wrote:
>>
>> On Aug 6, 2011, at 3:50 PM, Robin Holt wrote:
>>
>>> On Sat, Aug 06, 2011 at 11:52:45AM -0500, Kumar Gala wrote:
>>>>
>>>> On Aug 6, 2011, at 8:58 AM, Marc Kleine-Budde wrote:
>>>>
>>>>> On 08/06/2011 06:05 AM, Robin Holt wrote:
>>>>>> flexcan driver needs the clk_get, clk_get_rate, etc functions
>>>>>> to work.  This patch provides the minimum functionality.
>>>>>
>>>>> This patch has to go via the powerpc git tree. Added
>>>>> linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org on CC.
>>>>>
>>>>>> Signed-off-by: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
>>>>>> To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
>>>>>> To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
>>>>>> To: U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
>>>>>> Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
>>>>>> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>>>>>> ---
>>>>>> arch/powerpc/platforms/85xx/p1010rdb.c |   78 ++++++++++++++++++++=
++++++++++++
>>>>>> 1 files changed, 78 insertions(+), 0 deletions(-)
>>>>
>>>> NAK.
>>>>
>>>> This doesn't look right at all.  We should be doing something based =
on the device tree node that isn't board specific.
>>>>
>>>> I believe Bhaskar has a version of flexcan support that he's been wo=
rking on cleanup up for upstream.
>>>
>>> That version may be similar to what is in the freescale BSP which put=
s
>>> the clock functions inside flexcan.c
>>>
>>> The powerpc arch already provides a means for individual boards to pr=
ovide
>>> the clock functions.  I am not posting this patch here for acceptance=

>>> for powerpc and I am sure I will get feedback there when I post to
>>> their mailing list.  I am posting it here only to show that the flexc=
an
>>> developers earlier assertion that this can and should be done in the =
arch
>>> tree is correct and will work for the p1010 assuming we can get chang=
es
>>> into the arch/powerpc directory to implement these clk_* functions.
>>
>> My point is that I don't think they should live in the arch code.  The=
 clk_* functions you want to implement are tied more the FlexCAN IP than =
anything arch specific.  As such I believe they should be in the driver.
>>
>> For example when FSL has a P9999 with FlexCAN on it, we should NOT hav=
e to add any arch code to support it.
>=20
> The Flexcan is found on ARM and now also on PowerPC SOCs. My current
> understanding is that the ability to set the clock source and divider i=
s
> only available on PowerPC SOCs and therefore it's clearly arch specific=

> and should go to arch/powerpc/sysdev/fsl_soc.c if it's common for all
> PowerPC platforms. What do you think?

There is a bit in the CAN-Controller that selects the clock (at least on
arm). The current driver just supports the bus clock. Support for the
other, the oscillator clock, has not been implemented so far.

IIRC the oscillator clock has a frequency that results in worse standard
timing than the bus clock.

cheers, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig1D62CFCFD655DC236D061506
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk4/rUQACgkQjTAFq1RaXHPmsACfYBw3LrMEt377WElOQC1ZKkZO
b20An0Vbo87boZNDuvE1r5+zow2zBPGl
=UmJn
-----END PGP SIGNATURE-----

--------------enig1D62CFCFD655DC236D061506--

--===============6430307093957029200==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============6430307093957029200==--
