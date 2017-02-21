From: Neels Hofmeyr <nhofmeyr@sysmocom.de>
Subject: Re: [PATCH net-next v3 1/8] gtp: add documentation
Date: Tue, 21 Feb 2017 02:12:45 +0100
Message-ID: <20170221011245.GB1961@my.box>
References: <20170213153624.14170-1-aschultz@tpip.net>
 <20170213153624.14170-2-aschultz@tpip.net>
 <20170220161552.tnewzagg4z4azikd@nataraja>
 <1839823227.173727.1487611687205.JavaMail.zimbra@tpip.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="LpQ9ahxlCli8rRTG"
Cc: laforge <laforge@gnumonks.org>, Jonas Bonn <jonas@southpole.se>,
        netdev <netdev@vger.kernel.org>,
        osmocom-net-gprs <osmocom-net-gprs@lists.osmocom.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        pablo <pablo@netfilter.org>
To: Andreas Schultz <aschultz@tpip.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sysmocom.de ([144.76.43.93]:64097 "EHLO mail.sysmocom.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750922AbdBUBVx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Feb 2017 20:21:53 -0500
Content-Disposition: inline
In-Reply-To: <1839823227.173727.1487611687205.JavaMail.zimbra@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--LpQ9ahxlCli8rRTG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Feb 20, 2017 at 06:28:07PM +0100, Andreas Schultz wrote:
> >> +A specific tunnel is only defined by the destination entity. Since the
> >> +destination port is constant, only the destination IP and TEID define
> >> +a tunnel. The source IP and Port have no meaning for the tunnel.
> >=20
> > Are you absolutely sure about this?
>=20
> Yes. It took me a while to realize this. The crux is this statement in TS=
 29.060,
> Section 7.3.1:

Also sounds right to me. When the tunnel is established, each side of a GTP
tunnel stores the other side's IP and TEID; port number is constant
(unfortunately, which is one of the ideas/reasons behind gtphub).

~N


--LpQ9ahxlCli8rRTG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJYq5QNAAoJENhpyTJk1IQ5NjYQAKwz5mrkwc9EJQNnlARG5gMh
g9d5gB8j0hfU3CWkMyCmX5JjYmpQIWtdIiisOZSHy1HBC43OsUHpijiYE8VukCoa
0nKGcb2xJD0gefk1RBoOY8bhZ9fjurU23FVZxM1dIW3gq4bNS2Krxf+x6vvVUotu
/PeR9QCNpocpyYhxu5wqigAyFxAjc3tCihLV5YLV3gwmdShRk2Pb/WJNojhxwUwX
R/0QckOEsV5lWQPHR5J575fOaCwkpRz9klMjzaLxkfzTa7awi9irRUh8sh7gQ7Yz
8o2AcU55Ed6uOAm9A/r7A5qjIRZqGAw3uKFdS4UZOHGnQr7BWzdX7EdINhP5Wb7o
bCz3caJod7w334IsrpPwOd3VaTRxiWO8CI83fje2NX85UGjzpWoQ6fGbv4Fp1giI
wnraywNkTDyulTZK/oKNbqNzXILmTZTYjIFUDFz9UCinYg03xThsw7g7neye8si/
edDj13mOMhYSOISlTlx5s9qtNo7KhRNTmdwZJz9McwBEC2tuaLtyShaiGlWCiFor
c5a0ZBY57ZlMdRPElHRArJ9XCduCd27uMDXCQxnr1gAmA8SWoaeniCqQBkyd/iIV
Nhl/UAXEoMC4wmPIxwIMXXwuHSX9QNLu0vEFVcnYXRWEP7kwd0Gqm4PUtt9eRMTf
ZzcyOvJhU+Jfzcurs2tK
=5Fo6
-----END PGP SIGNATURE-----

--LpQ9ahxlCli8rRTG--
