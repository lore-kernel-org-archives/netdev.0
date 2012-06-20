From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net-next tree
Date: Wed, 20 Jun 2012 13:33:48 +1000
Message-ID: <20120620133348.a9ff31a72ffd11818f574fe3@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__20_Jun_2012_13_33_48_+1000_2_WaiczBDualKph2"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Federico Vaga <federico.vaga@gmail.com>,
	Giancarlo Asnaghi <giancarlo.asnaghi@st.com>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Bhupesh Sharma <bhupesh.sharma@st.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__20_Jun_2012_13_33_48_+1000_2_WaiczBDualKph2
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net-next tree, today's linux-next build (x86_64
allmodconfig) failed like this:

ERROR: "clk_get_rate" [drivers/net/can/c_can/c_can_pci.ko] undefined!
ERROR: "clk_get" [drivers/net/can/c_can/c_can_pci.ko] undefined!
ERROR: "clk_put" [drivers/net/can/c_can/c_can_pci.ko] undefined!

Caused by commit 5b92da0443c2 ("c_can_pci: generic module for C_CAN/D_CAN
on PCI").  Maybe a missing Kconfig dependency/select?

I have used the net-next tree from next-20120619 for today.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Wed__20_Jun_2012_13_33_48_+1000_2_WaiczBDualKph2
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJP4UScAAoJEECxmPOUX5FEZFIP/1gN7qk1GBfHYBEUJtcRKeTU
pnJywtaUffgBvr+LJtF6eJITj+GjoqaUWZ/WXQweBNTcnUZsjE0c37LBweHi8BY8
YZuCl+TKJWrxpzF+DkjrwdI+FVLN9OjQWKtFmTcp6U5ej77hHR+y1p0ae3nSuVwT
4apdL3hx8BRppYyN0kPyyn+u2ztAuc2KjOkKEDn2Prtuil/uwnXq3TuLzFLJXBBR
EcL6i9k250HNZ44SlNEulQRz6vdzyDQ/asDhHJyRQ9u9BngT+q5lDCbd3PMxpDvm
6tKjfLr6lAJSlNlB0VOoacpYxxh7dMVaWORSnTFjhilJFNDvSypPc6/qaDtOUgyd
3ftRQwBbBC+auYltX8EQCyGB+VUYUyVK6S09KvzB178uBdbMVhnA/hAYitDuw012
Flh0fozKw0iwrXkL1RCTjlGYI6vCg08Tmlp/+zYgUMWerHBpBs80hoDdpzKkRC+v
W5LTs3sRIn1pLzHV8T7b7sGLgAOZFuk28+xTEHKc/LHqJPTLMZbBO7+khX0ORARn
l/mDwgBNoE0wVQsM3Gw4RPe6Wr9ItgcctxVqOZ+6EhV+lfgSO+pTdZlcTXzCUCZo
B37+ABx3uSWgwTLyQnF9KAGQhx/amyjfZmk8nqV80KiU7Yq9o5C7uitzPrtvlSW9
1XuYEVg266iL9CvdEz1j
=qyxe
-----END PGP SIGNATURE-----

--Signature=_Wed__20_Jun_2012_13_33_48_+1000_2_WaiczBDualKph2--
