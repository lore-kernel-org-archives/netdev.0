From: Jeff Kirsher <tarbal@gmail.com>
Subject: Re: [PATCH] e1000: save skb counts in TX to avoid cache misses
Date: Thu, 07 Jun 2012 14:38:17 -0700
Message-ID: <4FD11F49.5060805@gmail.com>
References: <b838d871c0d507787373061e4edd91a624d62475.1339073391.git.rkagan@parallels.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="------------enigE642B2980386C2A2F2126EEB"
Cc: stable@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Dean Nelson <dnelson@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Roman Kagan <rkagan@parallels.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b838d871c0d507787373061e4edd91a624d62475.1339073391.git.rkagan@parallels.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigE642B2980386C2A2F2126EEB
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 06/07/2012 05:49 AM, Roman Kagan wrote:
> [Upstream commit 31c15a2f24ebdab14333d9bf5df49757842ae2ec with paths
> adjusted to compensate for the drivers/net/ethernet/intel reorg in
> dee1ad47f2ee75f5146d83ca757c1b7861c34c3b]
>
> Author: Dean Nelson <dnelson@redhat.com>
> Date:   Thu Aug 25 14:39:24 2011 +0000
>
>     e1000: save skb counts in TX to avoid cache misses
>
>     Virtual Machines with emulated e1000 network adapter running on Par=
allels'
>     server were seeing kernel panics due to the e1000 driver dereferenc=
ing an
>     unexpected NULL pointer retrieved from buffer_info->skb.
>
>     The problem has been addressed for the e1000e driver, but not for t=
he e1000.
>     Since the two drivers share similar code in the affected area, a po=
rt of the
>     following e1000e driver commit solves the issue for the e1000 drive=
r:
>
>     commit 9ed318d546a29d7a591dbe648fd1a2efe3be1180
>     Author: Tom Herbert <therbert@google.com>
>     Date:   Wed May 5 14:02:27 2010 +0000
>
>         e1000e: save skb counts in TX to avoid cache misses
>
>         In e1000_tx_map, precompute number of segements and bytecounts =
which
>         are derived from fields in skb; these are stored in buffer_info=
=2E  When
>         cleaning tx in e1000_clean_tx_irq use the values in the associa=
ted
>         buffer_info for statistics counting, this eliminates cache miss=
es
>         on skb fields.
>
>     Signed-off-by: Dean Nelson <dnelson@redhat.com>
>     Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> Signed-off-by: Roman Kagan <rkagan@parallels.com>
> ---
>  drivers/net/e1000/e1000.h      |    2 ++
>  drivers/net/e1000/e1000_main.c |   18 +++++++++---------
>  2 files changed, 11 insertions(+), 9 deletions(-)
Thanks! I have applied the patch to my queue


--------------enigE642B2980386C2A2F2126EEB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQIcBAEBCgAGBQJP0R9JAAoJEOVv75VaS+3O2jMP/1J+t5MfKY19/RyWFG/qHz5b
4QWZWuqKOL9hghK2e2fkYfFCrvrk0EKGUG1tKbI/AUA49LI+7ywK2Fhpv5wYebBa
Tj2AkVxN08UeB8DQzqqyTqoMwhJvbpWT6o8BM04mk49dEldwNo5FoXOuj16ymvLU
ju5il9SRm3LZWN2BMZT3Bf3Lp1dTC4mHmx4pLjwigaEAu/jVJT0sY2TURA3jvwg6
Ov+497Ygoo8Am8T4CkcE5S4Vnne6rxk740tWcWy8AR04+F3oadWiRnqiRXideYE3
tEOZgLLnMkEtaMunLQZ8lgXv3zC56sbx+X+napEopqoQPsKxh1QdLJ+7SNcVB9x5
iPOo3gKcp6NkdV4sAnw8vFNcr1BuQ9r7poXCbJWVvDAaItpRpmuDIAqsnoeaxqrt
knuWjyX0X96xOGvcgJ8BcV9C/US3VSLhkeSBv/YUo8jgkfbx4xRqxql57JiqmnEt
kYMaDzoKdjP3JYdXd53b13IICancRGAkwv7/udyaYSVWoqA4d/+ASqyyniZPaQ6a
FluPhI1re3QOUEOatrfAiC34IK7TlHtgA0LniLc6jPYuuet9wH6TEtVJiDE4I85S
LTqqnhKpC0OnZw6eZ/3oK94L4F0A5HfWIX/c76xOL+Q30xu2o16LByCTNi4VZUWC
TLck42Sf4DgoEdiqobFy
=T082
-----END PGP SIGNATURE-----

--------------enigE642B2980386C2A2F2126EEB--
