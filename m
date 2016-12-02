From: David Lebrun <david.lebrun@uclouvain.be>
Subject: Re: [RFC PATCH net-next v2] ipv6: implement consistent hashing for
 equal-cost multipath routing
Date: Fri, 2 Dec 2016 10:29:08 +0100
Message-ID: <58413EE4.7090002@uclouvain.be>
References: <1480439718-18019-1-git-send-email-david.lebrun@uclouvain.be> <CALx6S37NF6rqbAeu=9o8nFFT3Z88=OqcMPsm0rc9-vEPGTCYbw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature";
        boundary="wXM59NdoAExgBaRpCIamklG86QHpPqXhb"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:44610 "EHLO
        smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753228AbcLBJ3I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 04:29:08 -0500
In-Reply-To: <CALx6S37NF6rqbAeu=9o8nFFT3Z88=OqcMPsm0rc9-vEPGTCYbw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--wXM59NdoAExgBaRpCIamklG86QHpPqXhb
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 11/30/2016 05:04 AM, Tom Herbert wrote:
> This is a lot of code to make ECMP work better. Can you be more
> specific as to what the "issues" are? Assuming this is just the
> transient packet reorder that happens in one link flap I am wondering
> if this complexity is justified.

Unconsistent hashing is an issue when the load balancer is in front of
stateful backends, keeping per-flow state. Also, if neighbors are
constantly being added and removed, flows are constantly changing nexthop=
s.

David


--wXM59NdoAExgBaRpCIamklG86QHpPqXhb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iEYEARECAAYFAlhBPuQACgkQjbzn67sZ6AOh+ACgio0a7Brpkq3W3pp6hSlXIUD+
WO8An1vBRUIlYPvYpHudc7gEl9LsFCNv
=UvuE
-----END PGP SIGNATURE-----

--wXM59NdoAExgBaRpCIamklG86QHpPqXhb--
