From: David Lebrun <david.lebrun@uclouvain.be>
Subject: Re: [RFC PATCH net-next v2] ipv6: implement consistent hashing for
 equal-cost multipath routing
Date: Fri, 2 Dec 2016 09:29:42 +0100
Message-ID: <584130F6.5080802@uclouvain.be>
References: <1480439718-18019-1-git-send-email-david.lebrun@uclouvain.be> <1480477952.3702850.803295033.367FD66D@webmail.messagingengine.com> <583E8646.2010402@uclouvain.be> <CAJieiUjPXNxXFJxPkbZUF03bfw_=0Dc9qG0CkYoE0qeXAn0kYg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature";
        boundary="GFi10CPI5UlCFqMcfDDLwtrbUEVOkvb4F"
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:50292 "EHLO
        smtp1.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755883AbcLBI3r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 03:29:47 -0500
In-Reply-To: <CAJieiUjPXNxXFJxPkbZUF03bfw_=0Dc9qG0CkYoE0qeXAn0kYg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--GFi10CPI5UlCFqMcfDDLwtrbUEVOkvb4F
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 12/01/2016 06:55 PM, Roopa Prabhu wrote:
> I think Its best for it to be a global setting, and thats why sysctl
> seems like the best way (unless there are other ways to set this
> globally via rtnetlink). If it helps, most hw switch vendors
> supporting this feature also provide a globally tunable knob and it is
> not on by default.

What I had in mind was to keep the global sysctl but also provide a
per-route attribute, which would default to the global sysctl.

David


--GFi10CPI5UlCFqMcfDDLwtrbUEVOkvb4F
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iEUEARECAAYFAlhBMPYACgkQjbzn67sZ6ANQnwCdEse/rDNAuwB9diHzHpe2VV35
QAcAlRia4yl2os0RHzVls8IZnuIoREg=
=6nYI
-----END PGP SIGNATURE-----

--GFi10CPI5UlCFqMcfDDLwtrbUEVOkvb4F--
