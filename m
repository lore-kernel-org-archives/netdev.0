From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH net-next 6/8] net: ethernet: annapurna: add wol helpers
 to the Alpine driver
Date: Fri, 10 Feb 2017 11:12:47 +0100
Message-ID: <20170210101247.pxie2wtkbgh4th7f@kwain>
References: <20170203181216.30214-1-antoine.tenart@free-electrons.com>
 <20170203181216.30214-7-antoine.tenart@free-electrons.com>
 <08b62752-8bb2-4633-c44f-74eb585e7e52@cogentembedded.com>
 <063D6719AE5E284EB5DD2968C1650D6DB027C6C3@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4209163939340556044=="
Cc: "thomas.petazzoni@free-electrons.com"
 <thomas.petazzoni@free-electrons.com>,
 "saeed@annapurnalabs.com" <saeed@annapurnalabs.com>,
 "arnd@arndb.de" <arnd@arndb.de>,
 'Sergei Shtylyov' <sergei.shtylyov@cogentembedded.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 Antoine Tenart <antoine.tenart@free-electrons.com>,
 "talz@annapurnalabs.com" <talz@annapurnalabs.com>,
 "rshitrit@annapurnalabs.com" <rshitrit@annapurnalabs.com>,
 "barak@annapurnalabs.com" <barak@annapurnalabs.com>,
 "davem@davemloft.net" <davem@davemloft.net>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
 "tsahee@annapurnalabs.com" <tsahee@annapurnalabs.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB027C6C3@AcuExch.aculab.com>
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


--===============4209163939340556044==
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="drbwwxfbvppzfunx"
Content-Disposition: inline


--drbwwxfbvppzfunx
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

On Mon, Feb 06, 2017 at 11:35:49AM +0000, David Laight wrote:
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] =
On Behalf Of Sergei Shtylyov
> > Sent: 03 February 2017 18:22
> > On 02/03/2017 09:12 PM, Antoine Tenart wrote:
> >=20
> > > +	if ((adapter) && (adapter->phy_exist) && (adapter->mdio_bus)) {
> >=20
> >     Now that's somewhat stupid looking... does the whole driver use thi=
s "style"?
>=20
> Not only that, in one of the two functions it is followed by:
>=20
> +	device_set_wakeup_enable(&adapter->pdev->dev, adapter->wol);
>=20
> Which assumes that 'adapter' is not NULL.
> Some verifiers will detect that as a possible NULL pointer dereference.
>=20
> Pointers should only be checked for NULL if there are valid reasons
> why they can be NULL in that code path.
> Getting there with a NULL pointer dues to some race condition isn't one o=
f them.

Totally agree, for the NULL checks and for the useless parenthesis. I'll
try to catch other examples of this in the driver.

Thanks!

Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--drbwwxfbvppzfunx
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCgAGBQJYnZIfAAoJEFxNi8it27zYeTEP/iLoZQdr0B7KXEzZVgXP63wK
l725HwxDIY8DwH0ervjD4afPT7kNDI55G8HY1Fr40cbc06dM0MaMFodiSwdKrTnY
2fNyyEcDRg40wFP91JTWyOakaBH7SOQDpGqnetoWEXzT11/TW2QtsWVL5OywOfyS
+DnvVnq2DMHvlE4DkYjTgpe4+wi/RqL23VKiRqheGfev0P2nxg+Y7BM9tI4niA/w
7eK1VY/I7nsmdmpios4oPCpwidb+MNAgQ0WbRFUr9DDul9niRciH2Ng+tBiUz0mZ
JXSY2Ha85NJpQmUv/nsQqP1WgShRQc3hVt1bNgCRYuSJmzy/ajdi2F0XhTaZEGar
PGlig/+JyFqUNB3YihJrqfD1bRLrt6Svn1lGE6TifQLkl9RvfZlGba+70dLm8L7O
QKKGvb47ktcWOpsEBwxCnNjnXz0VfaTd58jeo4GD11lGpmHYKRLYjvV9ooFlMyF9
tZpQt5hGixUGJ9t9J01hadG5JSGlDwfcfG7U4hW8AEu4g1oR3+D2g0q8JUigBuhG
KFFgH/D4yxrlp8hSYASDh0Lbc/QIerHvLnulIH+lUsE8XLPTHieZLbClVjUIMPag
V7MJc4/96hFQ9JUUNygh6j/4AXGdDRd7W6q5mTuDvER9/puYJp3+dBHuo1UWkdCG
JsSlwMuq7jNFB/5L/W4b
=RQy4
-----END PGP SIGNATURE-----

--drbwwxfbvppzfunx--


--===============4209163939340556044==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
linux-arm-kernel mailing list
linux-arm-kernel@lists.infradead.org
http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

--===============4209163939340556044==--
