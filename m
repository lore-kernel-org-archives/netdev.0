From: David Lebrun <david.lebrun@uclouvain.be>
Subject: Re: [RFC 2/9] ipv6: sr: add code base for control plane support of
 SR-IPv6
Date: Thu, 1 Sep 2016 15:25:14 +0200
Message-ID: <57C82C3A.6090409@uclouvain.be>
References: <1472226767-9904-1-git-send-email-david.lebrun@uclouvain.be>        <1472226767-9904-3-git-send-email-david.lebrun@uclouvain.be> <20160831101028.7ea13fb4@xeon-e3>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature";
        boundary="HISnkbh8AaIBC0xiRQl9GBbNNWFchPkKs"
Cc: <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:38061 "EHLO
        smtp3.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752372AbcIANYr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 09:24:47 -0400
In-Reply-To: <20160831101028.7ea13fb4@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--HISnkbh8AaIBC0xiRQl9GBbNNWFchPkKs
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 08/31/2016 07:10 PM, Stephen Hemminger wrote:
> Since these are for control operations why a mutex?

I am not sure to understand the question. The spinlock is used on the
RCU write side of the namespace-wide parameters to prevent concurrent
writes.

David


--HISnkbh8AaIBC0xiRQl9GBbNNWFchPkKs
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iEYEARECAAYFAlfILDoACgkQjbzn67sZ6ANz/QCeO2x0xDBE+H6wZXtFGdQBvktG
PRkAnRWbWvnlb+gUd4X1oRJscRVVNo71
=uUkZ
-----END PGP SIGNATURE-----

--HISnkbh8AaIBC0xiRQl9GBbNNWFchPkKs--
