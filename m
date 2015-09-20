From: Matthew Monaco <Matthew.Monaco@Colorado.EDU>
Subject: Re: sr-iov and bridges (mlx4)
Date: Sun, 20 Sep 2015 10:21:18 -0600
Message-ID: <55FEDCFE.30506@colorado.edu>
References: <55FDF69F.6000105@colorado.edu>
 <CAJ3xEMg1HR+WfhUNMCu9mnXp6F9Vuw8=VkrUvcynAn3VWoP2Gw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="pAFbv6gXkHpb8th9UDobOIGPkDmEjiCmG"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:36546 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753792AbbITQVb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Sep 2015 12:21:31 -0400
Received: by igcrk20 with SMTP id rk20so46690735igc.1
        for <netdev@vger.kernel.org>; Sun, 20 Sep 2015 09:21:30 -0700 (PDT)
In-Reply-To: <CAJ3xEMg1HR+WfhUNMCu9mnXp6F9Vuw8=VkrUvcynAn3VWoP2Gw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--pAFbv6gXkHpb8th9UDobOIGPkDmEjiCmG
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 09/20/2015 05:01 AM, Or Gerlitz wrote:
> On Sun, Sep 20, 2015 at 2:58 AM, Matthew Monaco
> <Matthew.Monaco@colorado.edu> wrote:
> [...]
>> In all cases, VMs with SR-IOV work fine, IP on the host works fine, ou=
tbound
>> DHCP from the virtio VMs work fine, but inbound frames are not making =
it back to
>> the VM.
> [...]
>> Is there a know limitation of mixing SR-IOV and bridges in general? Do=
es the
>> SR-IOV switch specific to the mlx4 hardware not work well with linux b=
ridges? ...?
>=20
> It would be a bit hard for bridge based promiscuous environment to work=
 OOB
> for one of the functions (PF or VF) in SRIOV, this is generic issue,
> and not related
> to specific vendor.
>=20
> You need to use the bridge (8) tool (part of iproute2) and add the P.V
> VM MACs to
> the PF interface as "self" see some slides  (21/22/23) from netdev 0.1
> that deal with that
> https://netdev01.org/docs/netdev_tutorial_bridge_makita_150213.pdf
>=20
> Or.
>=20
> It also possible to mark one bridge port (the PF) as non-promiscuous,
> but I haven't
> played with that myself yet (slide 32), so can't just send you doing it=
=2E..
>

Many thanks, that helps. Now to figure out the best approach for shoving =
this
into OpenStack =3D)


--pAFbv6gXkHpb8th9UDobOIGPkDmEjiCmG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCgAGBQJV/t0DAAoJEAi+uryZEuPog5cIAIRF87yXwDV/1au+zQIa1i7o
UnncdA/lPyplcLf8VE1OJtxtQoF9ERguam/r0CXiPyrNZ0nIxNbyCtI1GQwEkgnv
qVBOH0Nn3GqBI33ijoMdcL6/Nwp57J58KNk/gtcu4GalxyDELRwSpcC3TLsWoMS0
4Y/+ujnsTFKK6EP+GK+THLbKM+J3exbt5+6IFvUgJY+15JjRi3rvTaRZyAHPXnP3
okk/w6OJqRvC0CRNiRcf/dnJ36sLTdftfrMxAfUTsdRO/Ck+SKb9y+IA85+2nuaC
BBbFfSA+AHq9YMShYa1yNVXXD3czw+z/eKGIePSRlgwUfmynXSGIMTn2DFA0lwQ=
=qh6j
-----END PGP SIGNATURE-----

--pAFbv6gXkHpb8th9UDobOIGPkDmEjiCmG--
