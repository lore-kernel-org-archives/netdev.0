From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCHv3 net] i40e: Implement ndo_gso_check()
Date: Thu, 04 Dec 2014 10:46:25 -0800
Message-ID: <1417718785.2404.5.camel@jtkirshe-mobl>
References: <1417718366-14310-1-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-jC5Fd97JZ91L62YSU9P6"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jesse@nicira.com, shannon.nelson@intel.com,
	jesse.brandeburg@intel.com, therbert@google.com,
	linux.nics@intel.com
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417718366-14310-1-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-jC5Fd97JZ91L62YSU9P6
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-12-04 at 10:39 -0800, Joe Stringer wrote:
> ndo_gso_check() was recently introduced to allow NICs to report the
> offloading support that they have on a per-skb basis. Add an
> implementation for this driver which checks for IPIP, GRE, UDP
> tunnels.
>=20
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> ---
> v3: Drop IPIP and GRE (no driver support even though hw supports it).
>     Check for UDP outer protocol for UDP tunnels.
> v2: Expand to include IP in IP and IPv4/IPv6 inside GRE/UDP tunnels.
>     Add MAX_INNER_LENGTH (as 80).
> ---
>  drivers/net/ethernet/intel/i40e/i40e_main.c |   26
> ++++++++++++++++++++++++++
>  1 file changed, 26 insertions(+)

Thanks Joe, I will add your patch to my queue.

Jesse Gross/Tom- If you guys are OK with the latest patch, I will move
forward with adding this patch to my queue.

--=-jC5Fd97JZ91L62YSU9P6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUgKwBAAoJEOVv75VaS+3OGSoP/3IiURx6dK43zFEZlCbTo1mz
beoWD2k0SQylvCwxnbbDp9dmjsg3zKwiIaQhBFPfhrHMKETw4+EFPLcpYF45ugvF
2v3sODD/UdtttJZ3Hi5F22fElQRmT5ZQHX0X+JkDMSwsOsHVG6CruGv2SpvD4kyE
HSVJNAcokTzHqGVfSSaILM1KchafwzeWneSQfLhoIS1/c5sQsxo2o7By8C3KnT5v
RDu+zYHIrdVarGoyx+Jz5OBn/WOv8x1ypyOmaVCu45VGrP21G4gfldw2bqSAJsBv
9qhO2Z+T2RswRqOUI9wNyzmdM/oFT1w6LIS6QuADqubwRxkd7MUSZXw1650Iue7k
yrCTuS4mXr3TWcq18AyWIinlopUmIzwEhnVm68fLUnPQhr55UmHZlb3xfaY28UJQ
oMBvknLBGSfrrmmnhDLjeM9h7NmeI2XQPDar4sj9HElOKP7ri3796UbQP/TU4Xjx
zDEmKlyttV7nwchyLziBtm9+SXNPUF4h5ltkQbcoV51O/oZYJvy4PfgtsO7F16T0
ZY6LLqR9RxXsJDULpzFywm4R8WeiHBmjMG4HCYR1IsLmdLmEtxd22rm3tXXjlb+k
X4ukVsO/AwJ0Qp3HeV66tACFDuCcRN95a6MZsmstJZOK2Kl4q56veRs3Sd4UOw+P
3ANgpYr/6OPQPhvgA58x
=OGxd
-----END PGP SIGNATURE-----

--=-jC5Fd97JZ91L62YSU9P6--
