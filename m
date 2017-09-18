From: hiren panchasara <hiren@strugglingcoder.info>
Subject: RACK not getting disabled
Date: Mon, 18 Sep 2017 13:14:28 -0700
Message-ID: <20170918201428.GB28186@strugglingcoder.info>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="JYK4vJDZwFMowpUq"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from strugglingcoder.info ([104.236.146.68]:56636 "EHLO
        mail.strugglingcoder.info" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750948AbdIRUTb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 16:19:31 -0400
Received: from localhost (unknown [10.1.1.3])
        (Authenticated sender: hiren@strugglingcoder.info)
        by mail.strugglingcoder.info (Postfix) with ESMTPA id CD69E17EED
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 13:14:28 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--JYK4vJDZwFMowpUq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all, I am trying to disable rack to see 3dupacks in action during
loss-detection but based on the pcap, I see that it's still trigger
loss-recovery on the first SACK (as if RACK is still enabled/active).

Here is what I did to disable rack:
net.ipv4.tcp_recovery =3D 0

I've also disabled metrics:
net.ipv4.tcp_no_metrics_save =3D 1=20
And also flushed existing entries with 'ip tcp_metrics flush' just to be
on a safer side.

Not really relevant here but I've also switched to reno.

I am on: 4.10.0-33-generic
pcap: https://transfer.sh/mfoiN/reno_no_rack.pcap

What am I missing? I can provide any additional info.

Cheers,
Hiren

--JYK4vJDZwFMowpUq
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQF8BAABCgBmBQJZwCkgXxSAAAAAAC4AKGlzc3Vlci1mcHJAbm90YXRpb25zLm9w
ZW5wZ3AuZmlmdGhob3JzZW1hbi5uZXRBNEUyMEZBMUQ4Nzg4RjNGMTdFNjZGMDI4
QjkyNTBFMTU2M0VERkU1AAoJEIuSUOFWPt/lG1UIAKC19TmIgtZgSocVUcoufNUY
qcBrK+bfnTJ4zJXxV/bHA5NRM6aHEEN/w4JhRql6yPdn46u3oaLsHKdmldxxw7/i
OIcOxVIVVMmSyH+gh0qK0wA3CK7Nb+Gss1wmPOiDR3DClOqsaoJX1VDtzTTGbEcX
n9NrnSjDAOVMva2G/L83fjH9qrYGgsx6xdZ8KANRVXCcPwiJ/gkOjaTzsCgxedmA
1GBNYL2NKuNX8GVZDhsQouHcXCtscgX8CSuK5Ap6lEtXBvJDPIkgWa1kIxld5GZg
KaoF0QbujpYhTjXroQCL3l3ZPg/8XanWi9IZp0GdHYzrjm/FIOwxm/hKrsTsiUY=
=Zh0/
-----END PGP SIGNATURE-----

--JYK4vJDZwFMowpUq--
