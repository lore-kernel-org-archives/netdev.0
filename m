From: Daniel Borkmann <danborkmann@googlemail.com>
Subject: Re: bug report: netpoll: allow execution of multiple rx_hooks per
 interface
Date: Wed, 10 Mar 2010 12:13:31 +0100
Message-ID: <4B977EDB.5010202@gmail.com>
References: <20100306110659.GE4958@bicker>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig3EA234831D978B97C59F0C49"
Cc: Daniel Borkmann <danborkmann@googlemail.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:24870 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751374Ab0CJLOR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Mar 2010 06:14:17 -0500
Received: by fg-out-1718.google.com with SMTP id l26so2153584fgb.1
        for <netdev@vger.kernel.org>; Wed, 10 Mar 2010 03:14:16 -0800 (PST)
In-Reply-To: <20100306110659.GE4958@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig3EA234831D978B97C59F0C49
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hi Dan,

Dan Carpenter wrote:
> Smatch complains about 508e14b4a4f: netpoll: allow execution of multipl=
e=20
> rx_hooks per interface
>=20
> net/core/netpoll.c +840 netpoll_setup(124) error: potential null derefe=
rence 'npinfo'.  (kmalloc returns null)
>    839          if (!ndev->npinfo) {
>    840                  spin_lock_irqsave(&npinfo->rx_lock, flags);
>=20
> 	npinfo can be null here if the kmalloc() failed.
>=20
>    841                  list_for_each_entry_safe(npe, tmp, &npinfo->rx_=
np, rx) {
>    842                          npe->dev =3D NULL;
>    843                  }
>    844                  spin_unlock_irqrestore(&npinfo->rx_lock, flags)=
;
>    845
>    846                  kfree(npinfo);
>    847          }

Sorry for the late reply, I'm currently on holiday and have hardly
access to the Internet. I'll fix the problem as soon as possible.

You'll hear from me.

Thanks,
Daniel


--------------enig3EA234831D978B97C59F0C49
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkuXftsACgkQ5AxJm1m3CC/s2QCcDlkg2KZUTfCxeqLNHf45XSJn
rD4An39hy5Vcfftu0tsIw5CN1wXSWif1
=rg1i
-----END PGP SIGNATURE-----

--------------enig3EA234831D978B97C59F0C49--
