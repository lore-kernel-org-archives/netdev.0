From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: merge of the wireless-next tree into the net-next tree
Date: Wed, 4 Jan 2012 10:59:47 +1100
Message-ID: <20120104105947.8bac77d1d7198a49e6feeca8@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__4_Jan_2012_10_59_47_+1100_pBA0mO36a3BOHXo3"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Kalle Valo <kvalo@qca.qualcomm.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__4_Jan_2012_10_59_47_+1100_pBA0mO36a3BOHXo3
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

I noticed that the wireless-next tree has been merged into the net-next
tree today.  Has anything been done about the build failure I reported in
the wireless-next a while ago:

On 12/22/2011 16:58 +1100, Stephen Rothwell wrote:
>
> After merging the final tree, today's linux-next build (powerpc
> allyesconfig) failed like this:
>=20
> drivers/net/wireless/ath/ath6kl/cfg80211.c:27:1: error: expected ')' befo=
re 'KBUILD_MODNAME'
> drivers/net/wireless/ath/ath6kl/cfg80211.c:27:1: error: 'KBUILD_MODNAME' =
undeclared here (not in a function)
> drivers/net/wireless/ath/ath6kl/cfg80211.c:27:1: error: expected ',' or '=
;' before string constant
> drivers/net/wireless/ath/ath6kl/init.c:32:1: error: expected ')' before '=
KBUILD_MODNAME'
> drivers/net/wireless/ath/ath6kl/init.c:32:1: error: 'KBUILD_MODNAME' unde=
clared here (not in a function)
> drivers/net/wireless/ath/ath6kl/init.c:32:1: error: expected ',' or ';' b=
efore string constant
> drivers/net/wireless/ath/ath6kl/init.c:33:1: error: expected ')' before '=
KBUILD_MODNAME'
> drivers/net/wireless/ath/ath6kl/init.c:33:1: error: invalid initializer
> drivers/net/wireless/ath/ath6kl/init.c:33:1: error: expected ',' or ';' b=
efore string constant
> drivers/net/wireless/ath/ath6kl/init.c:34:1: error: expected ')' before '=
KBUILD_MODNAME'
> drivers/net/wireless/ath/ath6kl/init.c:34:1: error: invalid initializer
> drivers/net/wireless/ath/ath6kl/init.c:34:1: error: expected ',' or ';' b=
efore string constant
>=20
> I can't figure out what goes wrong here.  On the compile command line,
> KBUILD_MODNAME is not defined, but KBUILD_BASE_NAME is.
>=20
> However, reverting commit fde57764ef87 ("ath6kl: enable USB support")
> made the problem go away.  That commit caused the above two files to be
> built into two separate modules.


There was some discussion, but I did not notice any fix (I may have
missed it).  I have been reverting that above commit ...
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Wed__4_Jan_2012_10_59_47_+1100_pBA0mO36a3BOHXo3
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJPA5ZzAAoJEECxmPOUX5FExPIP/32VmrVKxrn4h8MMIbZ/ouy2
0jX/DGq0OHT6dDWNxIG65NU71GOlVJ8uOVLl6jKrl0ZZ5+CWTaly/fKj7ekkegjH
wEmmbGrLUC7R+bOjXfX7jHkG0x35kivGihbM0K+I5QwkeHdOQiigOSG94iqDcBpt
m1V/Xj9VANHn7+WqwaVX6aoODNYz9KiKju08KIldu2Wn2C4wQK4NjFQPLGLeHufu
EeHRYy1tq6M+sIFKC+OffAdJQzCOTaPL34Ytrh6qgkSvmqPXz3pD/i+MBhPADBH6
TnGi3XqYzzTKNKdlV5xrGlYMdEa4c326UE8terajOiFuODXZSmojyoqga18MzKS0
aTVu9kbSZBqZRisvghoXR1G+/u3P2xbiqkbWJXKjAJ85Vl79GMgnGy5G57hegAsx
SvG0LcZIwtlX4g0VSGUtoMIxtV32vi7cwmCOfE4ABI19NLqQ6v6QG9IbGdZPHduz
k7xoddIjml7szbjGdFB+ouCB1QcOkFWSyDTK/5bV3UXBfjMe2dVvwf3KemGccTLg
yCbBfK5ulB9iLOEc/jCcv8ZI5shmhPn2DigbK8UucrdztI8Np3/pmCGv/j35F3eA
V1E82L1p/Sm2dfQi3WiGnhD+mOV31mEUEvXMuPoKW40YHkREI8FZ5M7MUuZIDd81
Q9LYsTK5VGKJqyhdt+08
=mCsb
-----END PGP SIGNATURE-----

--Signature=_Wed__4_Jan_2012_10_59_47_+1100_pBA0mO36a3BOHXo3--
