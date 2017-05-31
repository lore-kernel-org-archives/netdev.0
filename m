From: Ben Hutchings <ben@decadent.org.uk>
Subject: Leak in ipv6_gso_segment()?
Date: Wed, 31 May 2017 13:26:02 +0100
Message-ID: <1496233562.3992.10.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-qkhkTFbj+jav1IoWI6Vo"
Cc: netdev <netdev@vger.kernel.org>
To: Craig Gallek <kraig@google.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:54025 "EHLO
        shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751164AbdEaM0V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 08:26:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-qkhkTFbj+jav1IoWI6Vo
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

If I'm not mistaken, ipv6_gso_segment() now leaks segs if
ip6_find_1stfragopt() fails.  I'm not sure whether the fix would be as
simple as adding a kfree_skb(segs) or whether more complex cleanup is
needed.

Ben.

--=20
Ben Hutchings
Lowery's Law:
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0If it jams, force it. If it=
 breaks, it needed replacing anyway.

--=-qkhkTFbj+jav1IoWI6Vo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEErCspvTSmr92z9o8157/I7JWGEQkFAlkutloACgkQ57/I7JWG
EQlD6hAAmc5jKxYV9/UlGZg6rLhm1aD9KGxRl4LVTbxJXCQucTH+VgU9f7TLfS2y
k5tSv1gzcjydyKj1Hk2HeZsuB001wWEr7ncJhV86K5YCDm5p9GCQxQC5CgqV7krN
PpsbBQKQLa9TjNKjXI+NrItG3xpJ/GIoc1wKOAX4I46RI/PR2w/IFe467pewEOmF
N79xBsnYi3WXLAImK1rRcXyXDGTiOF4Hsz5XKjkGxpk5v/JE7ESl4l2WO46DQBUq
HTrOtB1H4NRGe16vJU8GOkp4x/b5s7/4rAYaRtLElzSkP6MF5Qi53ihY5FDuRiVI
sPw19eNjeaZ7VQbRBYwNN5SzRVIvpH+ZKT5hlDy/L1tXdHQC6pZe1SKIdAtLuQ4j
3eNUF3fu3fmGVa4Uwe46loJSg/YnX2uZTKzh+O5HV4TSJI0+nisJnO53Hpyv4xMR
eSLs6g+h+DzbALNN4QKH1VAzL9F2uJi54N7rShw3U+XfwIilKB0H7F/cpAltDDsG
g8Bn80QqXhHcFwVtuvU7e+ZMzEMEyiiMsJF7wlL6sOVnsh1XmfC8n9gQQhOvZ1Ti
Z4j8gkUQtKVtpFGut62FTIpiNMTokZ41UFrpJXqpg2/9POW7Dj3W9u7RRY0jyiSo
M+lwqNu0TcWieKrwv/i35nrygZt4+zCSoLBfVWm5PymSqm50MTE=
=xKK4
-----END PGP SIGNATURE-----

--=-qkhkTFbj+jav1IoWI6Vo--
