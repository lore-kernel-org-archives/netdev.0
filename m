From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [linux-nics] [PATCHv4 net] i40e: Implement ndo_gso_check()
Date: Fri, 05 Dec 2014 11:12:18 -0800
Message-ID: <1417806738.2404.42.camel@jtkirshe-mobl>
References: <1417804872-58635-1-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-/JLSzmwM3fWPYUpVgLir"
Cc: netdev@vger.kernel.org, linux.nics@intel.com, jesse@nicira.com,
	linux-kernel@vger.kernel.org, therbert@google.com
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417804872-58635-1-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-/JLSzmwM3fWPYUpVgLir
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-12-05 at 10:41 -0800, Joe Stringer wrote:
> ndo_gso_check() was recently introduced to allow NICs to report the
> offloading support that they have on a per-skb basis. Add an
> implementation for this driver which checks for IPIP, GRE, UDP
> tunnels.
>=20
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> ---
> v4: Simplify the check to just do tunnel header length.
>     Fix #define style issue.
> v3: Drop IPIP and GRE (no driver support even though hw supports it).
>     Check for UDP outer protocol for UDP tunnels.
> v2: Expand to include IP in IP and IPv4/IPv6 inside GRE/UDP tunnels.
>     Add MAX_INNER_LENGTH (as 80).
> ---
>  drivers/net/ethernet/intel/i40e/i40e_main.c |   12 ++++++++++++
>  1 file changed, 12 insertions(+)

Thanks Joe, I will update the patch in my queue with your latest
version.

--=-/JLSzmwM3fWPYUpVgLir
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUggOSAAoJEOVv75VaS+3ORPQP/icXPGo54pqmCAvn6/vxqjwC
xdSXAMJXlwESSlqEaMQBj3Y3s4diGVRDZKsF04wSu3f780fflmdVcmgsPuJSNl0D
2b1A3QV+Jz6H3co/asKni0pdmzk8NuuoT3J7cj1ZmInHJyaM1SYfYgqLRTvBgAsL
XQ+OhAC1NLSJO4LS3sGB0NDc2ZdBc/hA0ZpyrVL9CEkOhJZEw/LSMg6OT17LlMo+
BtmKxlsGrOQKC6HfyFazKm3sQ1jOML2IPhDcI9Oqu6xB0PQn3M5125qJWwyeKcU2
sghS2ZK3UQO/WDjeRcV00EIE7SuLhFV5eizImXxDE6+atmIafkAEFgvCpV5PcNW8
kSw8+lijY9Uo54JSVKaMwCoOik+Q0PMOyyJa4IS1AyqQ1ZUzDmWXVN5L18Lf2knc
4OP7H9k7vnpA10C33fVs221vRuXnx/YqDYQ8PoOosRqhvfVsjFFzJSeEur1HgNDs
meu+eUC9wNQqPqsZTIutmfMVd702N3Jughkyvl8uWvumuaiZlwt5nZ727m/MT4ej
deAyZcUJoBpQp8ObDtUYUVJbaZbMKeqcwka0EK59TeE1zmwu620N6OkJyxNmzw7f
9BCGzaF88MLJ18w2hN4ldwHxR7+P3W1ATpxuTLBeljkaBoJaGVPAqLHGwP6HViFn
i8kdW3QSX6zeGwIkdQAV
=nqLs
-----END PGP SIGNATURE-----

--=-/JLSzmwM3fWPYUpVgLir--
