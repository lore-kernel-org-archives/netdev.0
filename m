From: "Eggert, Lars" <lars@netapp.com>
Subject: Re: [CRIU] TCP_REPAIR MSS issue
Date: Tue, 14 Jun 2016 13:24:00 +0000
Message-ID: <183844BD-7118-44EB-9D97-62B2A164D7BC@netapp.com>
References: <C6D17923-7965-4483-8604-C654BFF1E0FF@netapp.com>
 <575FEA4B.2000603@virtuozzo.com>
 <3758708E-B5DE-4D8B-A8CC-37346F994B32@netapp.com>
 <1465909415.7945.182.camel@edumazet-glaptop3.roam.corp.google.com>
 <1465909802.7945.183.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_4851DEC8-AFDB-4DCC-9CF9-BCFB4D50DB85";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: Pavel Emelyanov <xemul@virtuozzo.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"criu@openvz.org" <criu@openvz.org>,
	Andrey Vagin <avagin@virtuozzo.com>,
	"Honda, Michio" <michio@netapp.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:48741 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752326AbcFNNY1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 09:24:27 -0400
In-Reply-To: <1465909802.7945.183.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_4851DEC8-AFDB-4DCC-9CF9-BCFB4D50DB85
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On 2016-06-14, at 15:10, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> What gives :
>> sysctl net/ipv4/ip_no_pmtu_disc net/ipv4/tcp_mtu_probing

net.ipv4.ip_no_pmtu_disc =3D 0
net.ipv4.tcp_mtu_probing =3D 0

> Also, is it a regression ? Was this working better with an older linux
> version ?

No idea, 4.6.0 is the only kernel I ran this on (is a new project). What =
would be a good older version to check?

Thanks,
Lars

--Apple-Mail=_4851DEC8-AFDB-4DCC-9CF9-BCFB4D50DB85
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJXYAVvAAoJEFS1wwm/cMFXPYAQAKjOmMnto0V5Z/IkhhJNOsuM
106wMLfmwuWZfiw64NFlU17wXaE0/3QCf+q4T3bTyC4hbwuW8/fUEO7dPLKn/pA3
Vh4/vTey8s8jgYZo5kJ3t4wG6dRzbNaSPkfk1dpq+q93ANIXpzKXCR1uU800TVIK
MbnThzVRu/2LFVhskcJ+mIF0WglKv+xbDPsD0TrCX+Zlm/ENvocB2hldLv8sJuFr
b7JZnW4qdiGE9ADYddh6HeafU9QR+929YC81nxmhM4wT8yDitbqDxJrVVVSOpHkp
MKB/pFRwP5Cjf6IrDgRq+wgz3rFA/Ekh8lmnvjqOB6B+RMzceRITImtzzkc5R3GG
FC23v6XqpbEdOnp9IMzQkxJIzZ+20nDgVNyjl6MXosP8hkyc29a9TGZH0NcoMxou
Q6lvMyLDJEOy3lqrWr/5bkFABKdb/cHYv/svn4FpDvJf0zJqqDuj+zHZQPFtunB8
qOyI6aYHXCOB82gfWvkhPgL8+ouR92yC1bZMahI43bojy4sOZSjh6z2DLvRKJng+
QQ4qdltZtn7zaR6/ZRo8EuY9TNfp8HzvOCoMvqnhbV1weVq+GQaDvQQAfxxG9exm
xtkIEyAx4kPNQFvUFKe2kkuRJ3rhVUYIRErDtvJgsidDSpcEqMdiX5R/z1xM4U26
qDQbzB8TTRF1vAMFJdc9
=helw
-----END PGP SIGNATURE-----

--Apple-Mail=_4851DEC8-AFDB-4DCC-9CF9-BCFB4D50DB85--
