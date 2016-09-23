From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net] i40e: fix call of ndo_dflt_bridge_getlink()
Date: Fri, 23 Sep 2016 14:37:18 -0700
Message-ID: <1474666638.2389.18.camel@intel.com>
References: <1474301694-13477-1-git-send-email-nicolas.dichtel@6wind.com>
         <60c90efd-fab3-84cd-f6e1-f6bc710c5ab7@6wind.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-Yj4hPzqoQUUU97g57zPE"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        Huaibin Wang <huaibin.wang@6wind.com>,
        Scott Feldman <sfeldma@gmail.com>,
        Carolyn Wyborny <carolyn.wyborny@intel.com>,
        Catherine Sullivan <catherine.sullivan@intel.com>
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:38796 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758358AbcIWVhT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 17:37:19 -0400
In-Reply-To: <60c90efd-fab3-84cd-f6e1-f6bc710c5ab7@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Yj4hPzqoQUUU97g57zPE
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-09-23 at 11:12 +0200, Nicolas Dichtel wrote:
> Le 19/09/2016 =C3=A0 18:14, Nicolas Dichtel a =C3=A9crit :
> > From: Huaibin Wang <huaibin.wang@6wind.com>
> >=C2=A0
> > Order of arguments is wrong.
> > The wrong code has been introduced by commit 7d4f8d871ab1, but is
> compiled
> > only since commit 9df70b66418e.
> >=C2=A0
> > Note that this may break netlink dumps.
> >=C2=A0
> > Fixes: 9df70b66418e ("i40e: Remove incorrect #ifdef's")
> > Fixes: 7d4f8d871ab1 ("switchdev; add VLAN support for port's
> bridge_getlink")
> > CC: Scott Feldman <sfeldma@gmail.com>
> > CC: Carolyn Wyborny <carolyn.wyborny@intel.com>
> > CC: Catherine Sullivan <catherine.sullivan@intel.com>
> > Signed-off-by: Huaibin Wang <huaibin.wang@6wind.com>
> > Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Hi Jeff,
>=20
> any news about this patch? David has marked it "awaiting upstream" on the
> patchwork, so I understand it should go to your tree.

Yes, it needs to go through my tree. =C2=A0 Please send it to intel-wired-l=
an@li
sts.osuosl.org=C2=A0mailing list, that way I can track it through our patch=
work
projects. =C2=A0Also you can trim Scott Feldman and Catherine Sullivan from=
 the
CC list.

http://patchwork.ozlabs.org/project/intel-wired-lan/list/
--=-Yj4hPzqoQUUU97g57zPE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJX5aCOAAoJEOVv75VaS+3OHGsP/1lYOQCtACne89jLlk3LHeMw
CtQCwfQ3DCprSlTu+90YA0imheBOS2CydmxRQpJUj5gSeN4VTUrMIZ4wuZgPrxmI
rS8XLXOLi3irj7Ryvb7UJHlQHI6RExV8N7uWf+NL6lDmSIEsfp86/reKLorw2cit
dz/v2BXGITgyLJK1deDzccOLnEU1xEOX0HO+70E591/fzeGWe+jGv1MFAKLY7MNR
+PtO1i8kdZ94Fc6vr0uFR2j3FYYUZc4G/2MCsJ/0cI0I57Mzh8uq++SUU5mQzYNW
cC0sXcaobkzxVpM/doiP/Vd0LmGQKUhIZAswtOURyTUR19kMcrjrm3wJw1cHX35W
R/xmjOMR0pP4IvpdVLzo5QFqq9c4YIiEoBik5UhSCMxuh4VwZbhnQ1YjSL42QzXM
mDVrwTtLclm9iRANdQLEUhgIc+1x3uCWfI7KeREFsLojswmkgstQyEJikDT2FJYE
uqE4KS0FthEky1mgHJBzeMK9dZ2VHKKWeoj75oeQAw37bqo8kkwgTPkIntFF89nf
U/8phnx+M9bn4MfFczfSgIyRVqfJENAIXYr2ZVsjVs27HdQA03yFlszJ+RMfzTWO
xKLrQsCs1TIHnzGatzBSFygc40PwbAm8LGzUkRqxtYRqJcWiILDV0zXp6nwyVuAl
SVS1baiKhLwla5GnaMJw
=DslD
-----END PGP SIGNATURE-----

--=-Yj4hPzqoQUUU97g57zPE--
