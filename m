From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the staging tree with the net tree
Date: Thu, 6 Oct 2011 15:58:10 +1100
Message-ID: <20111006155810.14a6b5c199edc388bbf11437@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__6_Oct_2011_15_58_10_+1100_cKPn4B3k/6FJ.7o6"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eliad Peller <eliad@wizery.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Arend van Spriel <arend@broadcom.com>
To: Greg KH <greg@kroah.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__6_Oct_2011_15_58_10_+1100_cKPn4B3k/6FJ.7o6
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Greg,

Today's linux-next merge of the staging tree got a conflict in
drivers/staging/brcm80211/brcmsmac/mac80211_if.c between commit
37a41b4affa3 ("mac80211: add ieee80211_vif param to tsf functions") from
the net tree and commit 3956b4a2ddb0 ("staging: brcm80211: remove locking
macro definitions") from the staging tree.

I fixed it up (which essentially means I used the staging tree version
with one small change to the brcms_ops_conf_tx prototype) and can carry
the fixes as necessary.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au


--Signature=_Thu__6_Oct_2011_15_58_10_+1100_cKPn4B3k/6FJ.7o6
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJOjTViAAoJEECxmPOUX5FEWzIP/jKQ49JUa4VXrq9QXLupOfvx
b++SLsKEPXnTrMkRrZxX/CusWPhvmHiNwaelE9xgqPaEvarNraBJkY9LOlw9uVB6
YIL1DTQ8DENbdMt5IdetuPy4NrX8EhAx3LSJpp4AkVX78xPTj5s8/OL78LNHtqdh
mu3IQvcRbilvdOoO5WF2v1stmsZSiJyVRT/F4eGAbswpVamqIgRT2cVUCLEDFLtP
4flAjrR9X6btBwYy5MmT8itlPy0hFQSzQHISxqIqVjU0Z99X3TY4bBM996NIsPp5
W2t+7GTjns3Bbh/F1A7Cw2MrEBGg4rlx01QLJjptjS6p4RVcAnbcpLp1urG7zkWC
8ykOAlun3wNGYeHM+PGGLnx5UVrwvgFjqBnDJMX5ONI//whLiynbdjpEgHeG4DCw
AmCn8a1jWqMHK7qN2PotIh+K+KsOh8VeORs/kiWPQpVfnsrdaXiSZWGJYdW8EjTU
7vY6QYrkc/fvvdonMyuQZmI79hg+xOje8y2LBE/kxT+WyBU8ODAxZxn+PrlM0n0F
bqxkFHBJScJgk/iGa710HjzRczUR3WWZAr0wuqSBoGYnURnyqFKKWIT0X8kirkZn
QE2Ie8h1xYBrUv/S6UEPpkjglFwLtbrO0vHT5ReaifwYsTqcetWDAsqTflvbnuJn
XjcQrMbPd6NEv2YB69pq
=2Vno
-----END PGP SIGNATURE-----

--Signature=_Thu__6_Oct_2011_15_58_10_+1100_cKPn4B3k/6FJ.7o6--
