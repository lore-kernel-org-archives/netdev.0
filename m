From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH] r8169: Fix rtl8169_rx_interrupt()
Date: Thu, 25 Mar 2010 13:30:38 +0200
Message-ID: <20100325113038.GA3471@swordfish.minsk.epam.com>
References: <20100307192305.GA598@elte.hu>
 <20100308125122.GA11242@redhat.com>
 <1268686865.2824.4.camel@edumazet-laptop>
 <1268699602.2824.14.camel@edumazet-laptop>
 <20100316145914.GB3332@swordfish.minsk.epam.com>
 <1268751933.3094.45.camel@edumazet-laptop>
 <20100316151023.GC3332@swordfish.minsk.epam.com>
 <1268752826.3094.48.camel@edumazet-laptop>
 <20100316182619.GA3451@swordfish>
 <1268765284.2932.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="3MwIy2ne0vdjdPXF"
Cc: Oleg Nesterov <oleg@redhat.com>,
	David Miller <davem@davemloft.net>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:48192 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754421Ab0CYL33 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Mar 2010 07:29:29 -0400
Received: by wwe15 with SMTP id 15so5786151wwe.19
        for <netdev@vger.kernel.org>; Thu, 25 Mar 2010 04:29:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1268765284.2932.17.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--3MwIy2ne0vdjdPXF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello,

On (03/16/10 19:48), Eric Dumazet wrote:
[..]
> OK thanks for the report, this rtl8169_reset_task() seems pretty buggy,
> or multiple invocation...
>=20
> Did you tried removing the rtl8169_schedule_work() call from
> rtl8169_rx_interrupt() ?
>=20
> Maybe the reset is not necessary at all in case of fifo overflow..
>=20
> Cumulative patch :
>=20
[..]

Eric, I think you can put Tested-by: Sergey Senozhatsky <sergey.senozhatsky=
@gmail.com>
on the cumulative patch as I don't see any errors with pktgen over LAN test=
ing.

Thanks.


	Sergey
--3MwIy2ne0vdjdPXF
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iJwEAQECAAYFAkurSV0ACgkQfKHnntdSXjRlbwP7B2taM4aZyQZGZa+NZwvbVv1s
xM3TgXr5WObeQd0lK3HDoJ7rBaviY5731a7sI5BSzC9erRLzxOixk6ORY3O6VSBw
oejlJg0LkI7voR3wGmm5Alg4bKcqAphhY/kb1hlSdWRGtUCBdO2iN822CW/Vc9zc
42raNsLliuVzgJ5lvzw=
=2Zb5
-----END PGP SIGNATURE-----

--3MwIy2ne0vdjdPXF--
