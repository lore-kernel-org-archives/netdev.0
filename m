From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 1/2] e1000e: Disable ASPM L1 on 82574
Date: Mon, 23 Apr 2012 16:18:15 -0700
Message-ID: <1335223095.2783.12.camel@jtkirshe-mobl>
References: <1335216578-21542-1-git-send-email-bootc@bootc.net>
	<1335216578-21542-2-git-send-email-bootc@bootc.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1458805598722695364=="
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	nix@esperi.org.uk, linux-kernel@vger.kernel.org
To: Chris Boot <bootc@bootc.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1335216578-21542-2-git-send-email-bootc@bootc.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============1458805598722695364==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Xk+shQirvZbQrZEHQliK"


--=-Xk+shQirvZbQrZEHQliK
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2012-04-23 at 22:29 +0100, Chris Boot wrote:
>=20
> ASPM on the 82574 causes trouble. Currently the driver disables L0s
> for
> this NIC but only disables L1 if the MTU is >1500. This patch simply
> causes L1 to be disabled regardless of the MTU setting.
>=20
> Signed-off-by: Chris Boot <bootc@bootc.net>
> Cc: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
> Cc: Nix <nix@esperi.org.uk>
> Link: https://lkml.org/lkml/2012/3/19/362
> ---
>  drivers/net/ethernet/intel/e1000e/82571.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)=20

I have added the patch to my queue, thanks Chris!

--=-Xk+shQirvZbQrZEHQliK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJPleM3AAoJEOVv75VaS+3ON4kP/16r+EnFpESXHKRXrCCvmKsm
Jr/ICtvj6GC9nWKt1ZU0hxWwUtA/ycNNolTMuqfK/gxhtPR+qDMXfQLjD1NWNP8B
wBD2gM5HyLUXYYoYFCx+6o62Pw76GbPx9qzYGusXKGxmSpjrTm1qGhn9VJ540ZAo
YCSQetmBcTcm1Yiq6aywZ+nsTUqx5iTYjO+Ee8QUlTmvriE43SCDQ5FmV3ckLQN7
ceuwg0PHgLLx4RDEurPu/9qDAEMp5Luic9o/3qEMDDYCitQTbEmi6UB2kFo5muzT
+LqRm+egRQDL0SVnhRVzRB+7/vUL5kc7pjsSYAYFwRsxzwcZH5HvclVaqtf9Axv0
Xnjf8M+aUn7mMdX7zMBJtjMJLdXSTGoIw8aDt/PtAkOdXqXtPoKDxoSQH3Q8vXvt
dpumsloZmP3gaPevIG+XlSjYOyPXNG2Gn/OCsI1FXZPzY9w7ppD1AH/MeH7rq/u0
1jbpLR3KgAyElyJdQZqJBUfp4rK5zo6Z71LXcU4nHViWkzBYmcb9/zNCvcYkYmK0
AemXp+lvgb2lvTvdkXJSiflO2Nj/XW3guhxhVXk4sLXx3JWegydvEoUOE/TyCiW2
a6nEqLRi78WO3y/tVKFUvgnLnzwGIBcImBbm5Fz79LFACAa45DG8aP/RHyT00X85
y/bVyg9HU9B6lkNcH/f7
=7Vpi
-----END PGP SIGNATURE-----

--=-Xk+shQirvZbQrZEHQliK--



--===============1458805598722695364==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
For Developers, A Lot Can Happen In A Second.
Boundary is the first to Know...and Tell You.
Monitor Your Applications in Ultra-Fine Resolution. Try it FREE!
http://p.sf.net/sfu/Boundary-d2dvs2

--===============1458805598722695364==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============1458805598722695364==--
