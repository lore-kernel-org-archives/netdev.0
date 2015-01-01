From: Christian Grothoff <christian@grothoff.org>
Subject: Re: [PATCH] TCP: Add support for TCP Stealth
Date: Thu, 01 Jan 2015 16:32:16 +0100
Message-ID: <54A56880.6040802@grothoff.org>
References: <54A470B3.3010501@sec.in.tum.de> <54A566F2.4070401@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="KaxBkjxRwwuDqn6vBrQuw4R8EslATiVfv"
Cc: netdev@vger.kernel.org, Jacob Appelbaum <jacob@appelbaum.net>,
	Pavel Emelyanov <xemul@parallels.com>
To: Daniel Borkmann <dborkman@redhat.com>,
	Julian Kirsch <kirschju@sec.in.tum.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.informatik.tu-muenchen.de ([131.159.0.99]:58094 "EHLO
	smtp1.informatik.tu-muenchen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750766AbbAAPkp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jan 2015 10:40:45 -0500
In-Reply-To: <54A566F2.4070401@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--KaxBkjxRwwuDqn6vBrQuw4R8EslATiVfv
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Dear Daniel,

That approach is highly vulnerable to timing attacks, and doesn't answer
how TCP clients without special capabilities could set the ISN correctly
either. Playing with raw sockets is the kind of geeky hack that is
unlikely to give us the combination of usability and security required
to significantly reduce the ongoing large-scale compromise of network
equipment by spy agencies.

Christian

On 01/01/2015 04:25 PM, Daniel Borkmann wrote:
>=20
> /me wondering (haven't tried that though) ... have you considered f.e.
> building a library using a raw packet socket with a BPF filter to captu=
re
> SYN packets and then TCP_REPAIR [1] to build a full-blown TCP socket ou=
t
> of it in case of a correct authentication from the ISN?
>=20
> Thanks,
> Daniel


--KaxBkjxRwwuDqn6vBrQuw4R8EslATiVfv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJUpWiAAAoJEJOea+Hin8PMv0AP/34DEjAzQaFfWS3uH4pyUOkI
RnY7cGTXS5EWbILOAZQBTUgaV4XjeTAx5WKb0uKVuyk5K6iDC2BvzUI5wmRtlJ8x
0sJSbsuzcbCffjkjeJSolrBzHlkwYSw1JrJxHXwNpjXo6AfaqiyVEjkyTrRU+1Zz
XQa6Bp0cbupmhAvLNOLerza3rWhWEsieE9YNDiaYi9MLPONko37N1fLl9oBSBdAs
6QqQhodC2al+ZObg1qmDWglvupxLsxQiIaJPm7qAv12FrRtPqVRwm83b5lVTkZVm
lC4G+4pnk6VJ7wI2PvRWrCwE1vMvsWjXfUw2e4ylKpx51lGaCUzHi+3YW/7r++Ee
TJDbnokrSo+IJC+ifsVVeu1Vt91nfd+W/+WufJM1UAZLUIEy1iY0oYIyQOE1FRtH
gFMe/fXr8EAXM4Avjv/bEB8lsnJWcAEJZ6sOzDjp7yRQ5U3p/bLsRLMYfSoYE4XO
n2bfOaf34KXobo2e0pVGPyW6hT3t+tEz5glWE9Kl/g+8GdL3FKTj+22G6xSJ6uBu
waAURwvPP5T3yIeeGQ9n6kPL373/4fjHeAqnrui8bDygf5QYmH2udEGGb9XKzw0M
ZshonIJ02Q5VxWbkwqxnVrIpEsN83wrBTbyAVbPij3TxBLGEqjD+uUI5qzQE/7Dn
szFXRSdEBsV+wFmiSzCy
=Rs52
-----END PGP SIGNATURE-----

--KaxBkjxRwwuDqn6vBrQuw4R8EslATiVfv--
