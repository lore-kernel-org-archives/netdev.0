From: "Eggert, Lars" <lars@netapp.com>
Subject: TCP_REPAIR MSS issue
Date: Fri, 10 Jun 2016 11:22:55 +0000
Message-ID: <C6D17923-7965-4483-8604-C654BFF1E0FF@netapp.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_A2223963-9437-46E7-B77A-AFEA43BEA025";
	protocol="application/pgp-signature"; micalg=pgp-sha256
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"criu@openvz.org" <criu@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:9617 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751419AbcFJLW7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2016 07:22:59 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_A2223963-9437-46E7-B77A-AFEA43BEA025
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

Hi,

I see an issue with TCP_REPAIR on kernel 4.6.0, where a migrated =
connection is only sending minimum-sized segments (~500 bytes), although =
the interfaces and path support Ethernet-sized MTUs. A connection that =
doesn't use TCP_REPAIR over the same path uses full-sized segments.

Know issue? Any workaround?

Thanks,
Lars



--Apple-Mail=_A2223963-9437-46E7-B77A-AFEA43BEA025
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJXWqMRAAoJEFS1wwm/cMFXma8P/2piEQJeGASchXDiGTpIEwG9
QhFcPF/WmZBzngX1InYKajtt1CU72OXSV82rlwy5z4NnUof0GMT282VPILw9KlqD
CAFLSA13iYXcYpE5hT3A9Q88OYnqBCNIAOW429IAvCDKcLrFU/ltBtO0IX5SbF3b
0MtljUrWgNgn/A9vUqh1K1NXnipT1GCGt0ZYgHgbiL3XMP97aqfV9zM9Ue2kKP7d
W3Ik5EIVL2b4/RB4Uv37tn4VpxjGmM8pZ56Y5mzCpYbnsrrN3ZuhXJ2gUURVJ/o3
11OWetq/2NHZybCo/xYXgE3aWHftk9TlFnpyxCQkKpZmuaf6u1bCWCy00XIrFFW6
MT2fDCpZ0jZ75ZRZ/Q/1XUyHiaUZ950CVN2T0RzRr1ucdp3PKOJ+vSYhbue7KgTH
zZnLzPK911b/L7uJuJyk9Xu996xrZoPWrww/RAckhWVs7DV7CEtxA6lG5/pPBisY
TjlrpxvpXBnDvkVfRnGnqU3apDw8YwGxcHlZ9OJEla9NQNnc0ouVp0VpQ84DWzoe
ZPFqSYW58+2AHaYneA4smzkBSTr77leBU6gbABrpuwleuocdX8W9oP8zLOnB9Xfh
0ypPqCD2TeBoSJPZQKVp4wdIeMPmMwICofqWQIVOLXeG8QhJTRSdkhr30fW781vG
yVLIJ9Bbkfo3Zpo1Tpgq
=kVEw
-----END PGP SIGNATURE-----

--Apple-Mail=_A2223963-9437-46E7-B77A-AFEA43BEA025--
