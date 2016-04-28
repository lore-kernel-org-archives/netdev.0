From: Doug Ledford <dledford@redhat.com>
Subject: Re: [PATCH net] RDMA/nes: don't leak skb if carrier down
Date: Thu, 28 Apr 2016 19:14:26 -0400
Message-ID: <57229952.5010309@redhat.com>
References: <1461529139-28582-1-git-send-email-fw@strlen.de>
 <20160428.142000.1837221734695213663.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="84H3kJ6aq0m2rVUSRE7Sa3W53rK0XVnlr"
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
To: David Miller <davem@davemloft.net>, fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54293 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753080AbcD1XPO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Apr 2016 19:15:14 -0400
In-Reply-To: <20160428.142000.1837221734695213663.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--84H3kJ6aq0m2rVUSRE7Sa3W53rK0XVnlr
Content-Type: multipart/mixed; boundary="xXXwTJ6JRFA7cj3fx68el6sNX3mL8O0oL"
From: Doug Ledford <dledford@redhat.com>
To: David Miller <davem@davemloft.net>, fw@strlen.de
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Message-ID: <57229952.5010309@redhat.com>
Subject: Re: [PATCH net] RDMA/nes: don't leak skb if carrier down
References: <1461529139-28582-1-git-send-email-fw@strlen.de>
 <20160428.142000.1837221734695213663.davem@davemloft.net>
In-Reply-To: <20160428.142000.1837221734695213663.davem@davemloft.net>

--xXXwTJ6JRFA7cj3fx68el6sNX3mL8O0oL
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 4/28/2016 2:20 PM, David Miller wrote:
> From: Florian Westphal <fw@strlen.de>
> Date: Sun, 24 Apr 2016 22:18:59 +0200
>=20
>> Alternatively one could free the skb, OTOH I don't think this test is
>> useful so just remove it.
>>
>> Cc: <linux-rdma@vger.kernel.org>
>> Signed-off-by: Florian Westphal <fw@strlen.de>
>> ---
>>  Noticed this while working on the TX_LOCKED removal.
>=20
> Assuming Doug will take this.

Thanks for mentioning this ;-)

They had sent to netdev and cc:ed linux-rdma, so I took that to mean
they intended for you to take it.  I'll pick it up for my upcoming pull
request.



--xXXwTJ6JRFA7cj3fx68el6sNX3mL8O0oL--

--84H3kJ6aq0m2rVUSRE7Sa3W53rK0XVnlr
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJXIplSAAoJELgmozMOVy/dU4MP/j3KR5eYjvbOgpDroN0bWEqx
UwtxS+zpGqbyE54BNSYQfV6hCH6qWr5xWcO7n6fCGJV+Ix0TG8kO57Sr8rBnDt8m
HMyxAZMkWLC6lYv9ONH++e99aizXGXC5Z5LKkdsYqBTtrMKKck+dCR2pi9sshE9/
m0N4nNEC0HcM0R6xmN+yjXhLKDHqfj+MFUYMQxbX0ySn61OVBB60PYdrLegfANzB
nFz30M8la310LH7wBiy6KQjb/5cZHe8dUB4pgKSaPj+ZXkQFpElA5t53oMbLGMAZ
H1W2A20ttFzkmucQQqN5WXkik0nvaqg567KF/ww01r9mrl/63NlFvebgNHXVKnVZ
GlNDHKzYLmHuQ2aAQGyH2ljsgfhvnwqfJqE4i8UQ+vKbEqa+iuXBECP4N1OAdUUx
OPZn1OxODuqpA5I4TSnXaqHfQhowLiy/Mcj2pnFYZa+Yd3BoLEtR/vZE5Eht0cLZ
A9tgPpAa/1Gwe+GBwUu95zWWBXx/IZiv388qwN5HrB39R4aAIa6OPQTk1CY8IsNS
Ii4W2poIw6Yv9ww3n0WkBjA3t2StEQLvCFwRLNFpUsFbGR8D//niQxoMgo2mrEMD
UV8s2avyNEcQam0jU7/Y2FuZXngP4xbofYZNbV75kUi6cYEbtJf0tNvebnaMmzcX
EIka9MBq6y4u8i99oYty
=Mtci
-----END PGP SIGNATURE-----

--84H3kJ6aq0m2rVUSRE7Sa3W53rK0XVnlr--
