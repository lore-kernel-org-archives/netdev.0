From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Wed, 20 Jun 2012 12:33:16 +0200
Message-ID: <4FE1A6EC.6070206@pengutronix.de>
References: <20120620133348.a9ff31a72ffd11818f574fe3@canb.auug.org.au> <D5ECB3C7A6F99444980976A8C6D896384FAA275CA8@EAPEX1MAIL1.st.com> <4FE18502.6040409@arm.com> <20120620.012037.783895812206310043.davem@davemloft.net> <20120620202604.407af721f746045ae00c8268@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig6BA6434F43A835D50614C9A8"
Cc: David Miller <davem@davemloft.net>, viresh.kumar2@arm.com,
	bhupesh.sharma@st.com, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	federico.vaga@gmail.com, giancarlo.asnaghi@st.com,
	wg@grandegger.com, spear-devel@list.st.com,
	Andrew Morton <akpm@linux-foundation.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120620202604.407af721f746045ae00c8268@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig6BA6434F43A835D50614C9A8
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 06/20/2012 12:26 PM, Stephen Rothwell wrote:
> Hi all,
>=20
> On Wed, 20 Jun 2012 01:20:37 -0700 (PDT) David Miller <davem@davemloft.=
net> wrote:
>>
>> From: viresh kumar <viresh.kumar2@arm.com>
>> Date: Wed, 20 Jun 2012 09:08:34 +0100
>>
>>> Please see following patchset from me, that got applied in linux-next=

>>>
>>> https://lkml.org/lkml/2012/4/24/154
>>>
>>> Please check if this patchset is present in your build repo. I believ=
e it should be
>>> there. If it is, then you shouldn't get these errors.
>>
>> Well, then Stephen shouldn't get those errors either.
>>
>> But obviously he did.
>>
>> But all of this talk about changes existing only in linux-next is
>> entirely moot.  Because The damn thing MUST build independently inside=

>> of net-next which doesn't have those clock layer changes.
>>
>> Someone send me a clean fix for net-next now.
>=20
> I get those errors because those patches are in the akpm tree which is
> merged after everything else ...
>=20
> One possibility is to put those changes in another (stable) tree and
> merge that into the net-next tree (and any other tree that needs it).

We're about to remove the offending clk_*() functions from the driver,
as they are untested anyway. The hardware the driver was developed for
uses a hardcoded clock rate in the driver anyway, as it cannot be
retrieved from clock tree. As soon as there is hardware available that
will work with the clock tree, we can add those functions back.

Sorry for the noise,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig6BA6434F43A835D50614C9A8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk/hpuwACgkQjTAFq1RaXHNE3wCeKwWQ+5LR0n4b5PpVlKhO5bjj
xwcAnighlfHs1b7EAny+CoK2sUaTPOsj
=BLOd
-----END PGP SIGNATURE-----

--------------enig6BA6434F43A835D50614C9A8--
