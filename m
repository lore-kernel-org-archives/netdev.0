From: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: pull request: bluetooth 2015-09-17
Date: Thu, 17 Sep 2015 15:27:17 +0300
Message-ID: <20150917122717.GA28252@t440s.lan>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="VbJkn9YxBvnuCH5J"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--VbJkn9YxBvnuCH5J
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

Here's one important patch for the 4.3-rc series that fixes an issue
with Bluetooth LE encryption failing because of a too early check for
the SMP context.

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit 20471ed4d403a5f4de6aa0c10cd1e446f7f2b3c7:

  dccp: drop null test before destroy functions (2015-09-15 16:49:43 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth.git for-upstream

for you to fetch changes up to d8949aad3eab5d396f4fefcd581773bf07b9a79e:

  Bluetooth: Delay check for conn->smp in smp_conn_security() (2015-09-17 12:28:27 +0200)

----------------------------------------------------------------
Johan Hedberg (1):
      Bluetooth: Delay check for conn->smp in smp_conn_security()

 net/bluetooth/smp.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

--VbJkn9YxBvnuCH5J
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJV+rGlAAoJECQj9vv5qNQSIFAP/1rxiD6DYyMCZmD+kK9tS1oo
DbWQJkrlNpJfXIR6nfhKukCSZY2d7JwaeUtWD+7/Pnj+yyVNkc/wbio0V7X+yr9g
Qs+OptkHTxaxOO5m9IqDeNaUAp+kJxJ2kOuCyJk+kcaxRHxEis+wIVvbbaiUpHwq
Q/6eokOQuH+WT2didgDVvXFcRRPj1QqASvx6yyIFUrM386K0UIBE3CXWqWvpnruC
oeijDYskGOdFNLvqpPhu+lkWQCh+KxGhEujFgIunCiPIsyOeMMq8PmgSFzsPgYTL
yKUgWChHsbJ9eUgG2E4X5GMebKq3+X613TQbNpMV0BAmU6tu0ICkiIMgdF5YhcVn
v9Ls0dhTv0WuqfOUkg5znkZuo3pKRQkUUyHyMNzAeG8wlsxzcb+dZXK9WXLqQwzD
og/jOy+WotwWxQsY1pvzTsEJuUFhrL269h19aAJlsBCGmFIQWyDKiZ9gnmCRyauX
JQxtXBdvkWQv2dv7n2MIisEwcL7eymBp6N8+p513FZLEkc+9FjsDE0QwCwspKPbC
HLIGBq3E40IiPA/D7TVme2X1iPnk+lua/vJcg9WdcLVd/6UMEJKZJaxhjCLfYoeU
Vkw0sdoBepmI/s4GYlWaUAc7MyC6GOBg4JImSR0ecu0Y3tyPBhZmS0N25/dTbE/b
1nQfaqNYoukbj0DFC+H2
=znSC
-----END PGP SIGNATURE-----

--VbJkn9YxBvnuCH5J--
