From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH 7/9] net: mvmdio: add xmdio support
Date: Wed, 7 Jun 2017 16:42:32 +0200
Message-ID: <20170607144232.GA4173@kwain>
References: <20170607083810.30922-1-antoine.tenart@free-electrons.com>
 <20170607083810.30922-8-antoine.tenart@free-electrons.com>
 <20170607121205.GC1271@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7614536209536111154=="
Cc: thomas.petazzoni@free-electrons.com, f.fainelli@gmail.com,
 jason@lakedaemon.net, netdev@vger.kernel.org,
 Antoine Tenart <antoine.tenart@free-electrons.com>, linux@armlinux.org.uk,
 gregory.clement@free-electrons.com, mw@semihalf.com, davem@davemloft.net,
 linux-arm-kernel@lists.infradead.org, sebastian.hesselbarth@gmail.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170607121205.GC1271@lunn.ch>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org


--===============7614536209536111154==
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="cNdxnHkX5QqsyA0e"
Content-Disposition: inline


--cNdxnHkX5QqsyA0e
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Wed, Jun 07, 2017 at 02:12:05PM +0200, Andrew Lunn wrote:
> On Wed, Jun 07, 2017 at 10:38:08AM +0200, Antoine Tenart wrote:
> > This patch adds the xMDIO interface support in the mvmdio driver. This
> > interface is used in Ethernet controllers on Marvell 370, 7k and 8k (as
> > of now). The xSMI interface supported by this driver complies with the
> > IEEE 802.3 clause 45 (while the SMI interface complies with the clause
> > 22). The xSMI interface is used by 10GbE devices.
>=20
> I've only take a quick look, but i don't see anywhere you look at the
> register address and see if it has MII_ADDR_C45 to determine if a C45
> transaction should be done, or a C22. The MDIO bus can have a mix of
> C45 and C22 devices on it, and you need to use the correct transaction
> type depending on the target device/address.

So this could be dynamic and not based on the compatible. I'll try this
and see if it can work.

Thanks!

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--cNdxnHkX5QqsyA0e
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJZOBDWAAoJEFxNi8it27zYyssP/RSdlfo/NqrV+5jV8k4oQRJe
DQ3buG2Fg0MxaB1mNhmRRmvYtCRono5FC20srHvzibp56QA3HgzqaG2U1qFFztRZ
+USDHv1NjHahCzo5y9gvJcXjsTeO5kYod1No14zIKEs5a2QvuvWGCojkEwEaC7Ig
bB0WBFTCaBeO+dkf12Qi2o+rAedKMXnRlKLaXmAvjyDTruSHPkje4QPNzHIAnwTx
MEbPr5CcRLQ514mGv8ghu1DO/sXa5WQeW/oaztbxf9Y4Xf4z79f5NWhE8Qo/Iiu7
hNp5UY3xaP0+JGt61ubYvYUKkeadGZm8c9svIY2GOjAWp6Q5IKQwKoz9f6wBjp+S
knBKNq36nOag4Ed0GeYDT0Wqjdsob0/SEHhcR+wzJSM42fbDTNvhZZqIWGQYcd7w
h6McwvX45OODAJBeREvTpz82Bu4Eg5c1ZoknFBvxkQ5J0TD83tCTuJebqLQHOFuz
VNzAxJSce5tP4kdvZSIiVob3SAWb6nRsDRFsQfih19T/dIEDYfPIbhlKgwvciqZc
dBIq519vybwXkt+JRDMNxH/3FL6kXnGwHHuAj4GiQ0/tq8j46EHcdwq366dmlcfc
ZTsL4dfrKMMQ9qY9CbncPYL/O8baAGktMJInNZ4kAeZqq3ccUj+rdKP1S1vwtEuJ
8TpU3LpfHIKUlfkZ0hdV
=BqxI
-----END PGP SIGNATURE-----

--cNdxnHkX5QqsyA0e--


--===============7614536209536111154==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
linux-arm-kernel mailing list
linux-arm-kernel@lists.infradead.org
http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

--===============7614536209536111154==--
