From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [PATCH net-next v3 1/3] random32: add prandom_u32_max and convert
 open coded users
Date: Sun, 19 Jan 2014 14:41:36 +0100
Message-ID: <52DBD610.7050907@imap.cc>
References: <1390088431-28657-1-git-send-email-dborkman@redhat.com> <1390088431-28657-2-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, hannes@stressinduktion.org,
	netdev@vger.kernel.org, Jakub Zawadzki <darkjames-ws@darkjames.pl>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:36139 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752086AbaASNs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jan 2014 08:48:26 -0500
In-Reply-To: <1390088431-28657-2-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Am 19.01.2014 00:40, schrieb Daniel Borkmann:

> @@ -38,6 +37,23 @@ struct rnd_state { u32 prandom_u32_state(struct
> rnd_state *state); void prandom_bytes_state(struct rnd_state
> *state, void *buf, int nbytes);
>=20
> +/** + * prandom_u32_max - returns a pseduo-random number in
> interval [0, ep_ro) + * @ep_ro: right open interval endpoint + * +
> * Returns a pseduo-random number that is in interval [0, ep_ro).
> Note + * that the result depends on PRNG being well distributed in
> [0, ~0U] + * u32 space. Here we use maximally equidistributed
> combined Tausworthe + * generator, that is, prandom_u32(). This is
> useful when requesting a + * random index of an array containing
> ep_ro elements, for example. + * + * Returns: pseduo-random number
> in interval [0, ep_ro) + */

The word "pseudo" is consistently mistyped as "pseduo" in this comment.
(Three occurrences.) You may want to correct this before it gets merged=
=2E

Thanks,
Tilman

- --=20
Tilman Schmidt                              E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=F6ffnet mindestens haltbar bis: (siehe R=FCckseite)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (MingW32)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlLb1hAACgkQQ3+did9BuFt4gACeMe9m893fMIapXiZ/AC7BERai
E/cAmgI6r1Uf1EE8reLA6nqd3T/FGWt6
=3D5qOJ
-----END PGP SIGNATURE-----
