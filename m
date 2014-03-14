From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next ] i40evf: Rename i40e_ptype_lookup
 i40evf_ptype_lookup
Date: Fri, 14 Mar 2014 16:13:13 -0700
Message-ID: <1394838793.2167.88.camel@jtkirshe-mobl>
References: <87k3bw2xjp.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-BpW/RJXk3c4+Qf57O8Nq"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Kavindya Deegala <kavindya.s.deegala@intel.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:34855 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754470AbaCNXNP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Mar 2014 19:13:15 -0400
In-Reply-To: <87k3bw2xjp.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-BpW/RJXk3c4+Qf57O8Nq
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-03-14 at 16:03 -0700, Eric W. Biederman wrote:
>=20
> When compiling the i40e and the i40evf driver into the same kernel I
> get:
> LD      drivers/net/ethernet/intel/built-in.o
> drivers/net/ethernet/intel/i40evf/built-in.o:(.data+0x300): multiple
> definition of `i40e_ptype_lookup'
> drivers/net/ethernet/intel/i40e/built-in.o:(.data+0x780): first
> defined here
> make[3]: *** [drivers/net/ethernet/intel/built-in.o] Error 1
> make[2]: *** [drivers/net/ethernet/intel] Error 2
> make[1]: *** [drivers/net/ethernet/] Error 2
> make: *** [sub-make] Error 2
>=20
> Fix this by renaming the i40evf version of this structure from
> i40e_ptype_lookup to i40evf_ptype_lookup.
>=20
> This build failure was introduced in:
> commit 206812b5fccb808d1194344eaa942f68f59b2630
> Author: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Date:   Wed Feb 12 01:45:33 2014 +0000
>=20
>     i40e/i40evf: i40e implementation for skb_set_hash
>=20
>     Original comment from Tom Herbert <therbert@google.com>
>=20
>        Drivers should call skb_set_hash to set the hash and its type
>        in an skbuff.
>=20
>     This patch builds upon Tom's original implementation and adds
>     the L4 type return when we know it is an L4 hash.
>     This requires use of the ptype decoder ring, so enable it.
>=20
>     Change-ID: I2f9fa86d1a6add58cff13386f7f4238b1abcc468
>     CC: Tom Herbert <therbert@google.com>
>     Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
>     Acked-by: Shannon Nelson <shannon.nelson@intel.com>
>     Acked-by: Mitch Williams <mitch.a.williams@intel.com>
>     Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
>     Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Cc: Catherine Sullivan <catherine.sullivan@intel.com>
> Cc: Kavindya Deegala <kavindya.s.deegala@intel.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
>  drivers/net/ethernet/intel/i40evf/i40e_common.c    |    8 ++++----
>  drivers/net/ethernet/intel/i40evf/i40e_prototype.h |    4 ++--
>  2 files changed, 6 insertions(+), 6 deletions(-)

Thanks Eric, I already have a patch in the queue that was to resolve
this which was going to be pushed after this last series I just sent
out.

--=-BpW/RJXk3c4+Qf57O8Nq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJTI40JAAoJEOVv75VaS+3OPngQAIuqCd9lWOhpiR0y+aCFT/4Q
LxUeNgW69ynYc0Zr8Fj3M9vlel7C9USZpkrMcsDLUMKzOjFaLAduB4r1TTmDAW4c
t0m7zsina4YdlIyXH06hRy75Auqg5TVXwn9uKKYmbPXbDh3p3Gh8ZO4c4sOMQE/W
UzgV8K1cbvDC0RyVuUMMLzktbQ+Z9fKIRtLwUyF7Q4RhV5Ezz0qx8ZvwwuyEzBSd
4gcv9My/ZB0Zzzu/0mgsb083X4PB7Vc/KLjyIyA/v+Rq5t0woh++/1ItILNENNlG
2BMgFYfnSP7bQvOHk+HUPt1Dg/OdW6MBqpgJ2B8ix0vBBtaGSPmviMCruednbphJ
yYXvObhZFPj+wIknQdr1vFoy0wQNmXOSreK0sIANadDXxM+iC2tLY+ByoC0Oe+Gu
c48fLpmi5fp8El1HAFHn7RI3xcTwwIBPTA99q+CFss75x4CVKSB761FsAD05yRdY
lwvThJT+g+xfoRymPLhPp6TmEGvu7OnvYSyRr2tXVQ5Sb3aa3mF5mdT4PJO6SMXX
LOFxo6u5niEoWsWePddP+0gcoqQPib6HL9jNynCxL2DRMQnpNlaHwBsdoQ3vSUuN
wt/yOaX7FBF/JOvoIqggHxOufj2e3jiXv831jgUQEuvD4srDjrVgC1x7hcYRgIja
+LSnwlnNlM9ymYwprT1p
=u3WI
-----END PGP SIGNATURE-----

--=-BpW/RJXk3c4+Qf57O8Nq--
