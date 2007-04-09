From: =?ISO-8859-1?Q?Sven_K=F6hler?= <skoehler@upb.de>
Subject: Re: Bridge & it's MAC address question
Date: Mon, 09 Apr 2007 20:30:12 +0200
Message-ID: <eve0nv$ang$1@sea.gmane.org>
References: <200610301527.15018.dim@openvz.org>
	<20061030072837.51177183@localhost.localdomain>
	<20061215131908.GC11579@xi.wantstofly.org>
	<20061215075236.321e6a07@localhost.localdomain>
	<20061215160429.GC12679@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0495348450=="
Cc: netdev@vger.kernel.org
To: bridge@osdl.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20061215160429.GC12679@xi.wantstofly.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/bridge>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--===============0495348450==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="------------enig1061B7BCFA9BE5D055CB8C32"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig1061B7BCFA9BE5D055CB8C32
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

>>>> The bridge physical address is the minimum of all the attached devic=
es.
>>>> This is done because the STP standard requires it.  You can reset it=

>>>> to be the same as any of the attached devices. This will not cause a=

>>>> problem unless using STP.
>>> You can in fact use any MAC address.  The STP standard recommends usi=
ng
>>> the minimum address, as that is deterministic, and so it doesn't depe=
nd
>>> on the order in which you enslave subdevices.
>> So should restriction be lifted?
>=20
> We should definitely allow users to override the MAC address of a
> bridge interface.

Yes, i would love to have that feature.

I'm using a bridge for a Xen host machine. Interfaces of the Xen guests
are dynamically added to and removed from the bridge. At the moment, i
create and add a tun interface to the bridge, so the bridge has a valid
mac address at all.



--------------enig1061B7BCFA9BE5D055CB8C32
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFGGoY07Ww7FjRBE4ARAhMiAJsGB9iky4m+w2mKJbSVlePBjkJUuwCfb85u
m0xiaTudL9NmPtJ7qfbF3rI=
=J6Zj
-----END PGP SIGNATURE-----

--------------enig1061B7BCFA9BE5D055CB8C32--


--===============0495348450==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

_______________________________________________
Bridge mailing list
Bridge@lists.linux-foundation.org
https://lists.linux-foundation.org/mailman/listinfo/bridge

--===============0495348450==--
