From: David Lebrun <david.lebrun@uclouvain.be>
Subject: Re: [PATCH 3/9] ipv6: sr: add support for SRH encapsulation and injection
 with lwtunnels
Date: Tue, 18 Oct 2016 13:47:02 +0200
Message-ID: <58060BB6.1020708@uclouvain.be>
References: <1476715350-18983-1-git-send-email-david.lebrun@uclouvain.be> <1476715350-18983-4-git-send-email-david.lebrun@uclouvain.be> <CALx6S355B9QzYor6AsSfEprE=CODnaJeE_5u9C3CtpMMe4dPog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature";
        boundary="G1FnirLMlvCgIRj1jWBtd2DNlPK1uSVRh"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:33485 "EHLO
        smtp4.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753541AbcJRLpb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 07:45:31 -0400
In-Reply-To: <CALx6S355B9QzYor6AsSfEprE=CODnaJeE_5u9C3CtpMMe4dPog@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--G1FnirLMlvCgIRj1jWBtd2DNlPK1uSVRh
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 10/17/2016 07:17 PM, Tom Herbert wrote:
>> > +       err =3D ip6_dst_lookup(net, sk, &dst, &fl6);
> Please look at the use of dst_cache that I added in ila_lwt.c, I think
> the SR has similar properties and might be able to use dst_cache which
> is a significant performance improvement when source packets from a
> connected socket. The dst_cache will work in LWT as long as the new
> destination address is the same and other input to routing (saddr,
> flow label, mark, etc.) are either always the same or assumed to be
> immaterial to lookup of the second route.
>=20

Great, thanks :)


--G1FnirLMlvCgIRj1jWBtd2DNlPK1uSVRh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iEYEARECAAYFAlgGC7kACgkQjbzn67sZ6APR2wCdFTnFfgSamyzzWkiWOJ+SXWCi
1kUAn1GrNzK4ChS4qN3VRMT0W6b6PA79
=iMRT
-----END PGP SIGNATURE-----

--G1FnirLMlvCgIRj1jWBtd2DNlPK1uSVRh--
