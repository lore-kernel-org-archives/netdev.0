From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [patch net-next v5 4/4] igb/igbvf: implement
 ndo_get_phys_port_id
Date: Fri, 26 Jul 2013 06:08:29 -0700
Message-ID: <1374844109.32309.10.camel@jtkirshe-mobl>
References: <1374840596-5748-1-git-send-email-jiri@resnulli.us>
	 <1374840596-5748-5-git-send-email-jiri@resnulli.us>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-6RTusz57YrMiCQJqsxyX"
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stephen@networkplumber.org, Narendra_K@Dell.com,
	bhutchings@solarflare.com, john.r.fastabend@intel.com,
	or.gerlitz@gmail.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	peter.p.waskiewicz.jr@intel.com, alexander.h.duyck@intel.com,
	john.ronciak@intel.com, tushar.n.dave@intel.com,
	matthew.vick@intel.com, mitch.a.williams@intel.com,
	vyasevic@redhat.com, amwang@redhat.com, johannes@sipsolutions.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:12882 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757620Ab3GZNIc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jul 2013 09:08:32 -0400
In-Reply-To: <1374840596-5748-5-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-6RTusz57YrMiCQJqsxyX
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2013-07-26 at 14:09 +0200, Jiri Pirko wrote:
> igb driver generated random number which will identify physical port.
> This id is available via ndo_get_phys_port_id directly on igb netdev.
> Also, id is passed to igbvf using mailbox. After that, it is available
> via
> ndo_get_phys_port_id on igbvf netdev as well.
>=20
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  drivers/net/ethernet/intel/igb/e1000_mbx.h |  1 +
>  drivers/net/ethernet/intel/igb/igb.h       |  2 ++
>  drivers/net/ethernet/intel/igb/igb_main.c  | 29
> +++++++++++++++++++++-
>  drivers/net/ethernet/intel/igbvf/igbvf.h   |  3 +++
>  drivers/net/ethernet/intel/igbvf/mbx.h     |  1 +
>  drivers/net/ethernet/intel/igbvf/netdev.c  | 40
> ++++++++++++++++++++++++++++++
>  drivers/net/ethernet/intel/igbvf/vf.c      | 34
> +++++++++++++++++++++++++
>  drivers/net/ethernet/intel/igbvf/vf.h      |  1 +
>  8 files changed, 110 insertions(+), 1 deletion(-)=20

Added this patch (actually the entire series) for testing.

--=-6RTusz57YrMiCQJqsxyX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJR8nTNAAoJEOVv75VaS+3OBZIP/R3cU49m4XR7Xm8gigXsjpTN
BJAISbNlFMgbuvOtOBvvPbMUf28iF81IOBGMtqi9TfYjaEoGwxXPN1D/+yO6ZyQK
dQY6ywF8V9uK5zqpE/SbetdgaiTcxkx3ccGKeb8iHYblKOj0bvk7q0ARZ1ljkI3W
VIUpqVzoc6yR80xf1t+r53n5OVpMFvyoGwMi5ollTWjlOO1Dw8eZ+F1Hzxju/vAI
dxXohuejshew6KFjZSOF6508ZC8KZF7uD1YSfp3SQ2dbs4BjeLUXAGG8eJ5kwStD
j8CWLanFHTSuIzOvxzeGk06EEc4wcFI8PhGxKVTPMIQnWi7T7yvwVWdzu8eOipbD
GrYcFi4SxfjNHcGrFi/NQsiMbm2rKPSvlHtF9fS5ejd6YDPxevzUPbefXFelfdaK
u1zMPUAeHn3vg6D12z+xkHV1FIqOfYWGN40nYq9EL5VFYQHCz/tNyJYQsr+NTkaz
gR7GMgY1OBmbyRHO1sii0jM91VNo0GRM5lLpAwUeTllRuIuUh4NdbW3ZAiyX0Uw6
uL6GI+xkNRsiQuELFok92I0Q3PiaRLlphv0/FU/+aFleVKU6YEXzKrwOWq3nxB8Q
tBkX5ky3iFzadtz9x58jER5hYydyaKC5/gQvGxZd0I4HN45Q5VQ9zXh0XKTi2VSk
+aNa3QpNbjrYRNc7PrOv
=ZDkG
-----END PGP SIGNATURE-----

--=-6RTusz57YrMiCQJqsxyX--
