From: David Lebrun <david.lebrun@uclouvain.be>
Subject: Re: [PATCH 4/9] ipv6: sr: add core files for SR HMAC support
Date: Tue, 18 Oct 2016 14:07:31 +0200
Message-ID: <58061083.7020609@uclouvain.be>
References: <1476715350-18983-1-git-send-email-david.lebrun@uclouvain.be> <1476715350-18983-5-git-send-email-david.lebrun@uclouvain.be> <CALx6S37FP3_3hp093tg=NWRaYTg_pWY_Yf5odYBYi1vYRjvyfg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature";
        boundary="Dhh9doC48WTldClvpd2a64KGKxWuSaxjd"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:42588 "EHLO
        smtp3.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750703AbcJRMGB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 08:06:01 -0400
In-Reply-To: <CALx6S37FP3_3hp093tg=NWRaYTg_pWY_Yf5odYBYi1vYRjvyfg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Dhh9doC48WTldClvpd2a64KGKxWuSaxjd
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 10/17/2016 07:24 PM, Tom Herbert wrote:
> A lot of this looks generic and potentially useful in other cases
> where we we want to do HMAC over some headers (I'm thinking GUE can
> probably use some of this for header authentication). Might be nice to
> split out the generic pieces at some point.

How would you see this integrated generically ? Directly into the crypto
subsystem ? The idea is interesting anyway, I can work on that after
this patch series goes through.


--Dhh9doC48WTldClvpd2a64KGKxWuSaxjd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iEYEARECAAYFAlgGEIcACgkQjbzn67sZ6AN6JACeMXFcWDK9YQ0ekn0hui/0aZOU
FkIAn1ZanFnYbyy8xYgag8y//7mAi3d6
=DJ5c
-----END PGP SIGNATURE-----

--Dhh9doC48WTldClvpd2a64KGKxWuSaxjd--
