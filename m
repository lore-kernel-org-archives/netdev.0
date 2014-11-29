From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: [PATCH] drivers:net:wireless: Add mutex locking for function,
 b43_op_beacon_set_time in main.c
Date: Sat, 29 Nov 2014 09:56:32 +0100
Message-ID: <20141129095632.69361457@wiggum>
References: <1417213013-19758-1-git-send-email-xerofoify@gmail.com>
	<CACna6rxmOC0h9hOpa=5iWFM1THQ8Q4hCi8MnmqkZJbB_U0PJ0A@mail.gmail.com>
	<20141129002148.1beb21d9@wiggum>
	<54793E4E.7050602@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/IwltwmK3kbFqBgFDBLIx14S"; protocol="application/pgp-signature"
Cc: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	Stefano Brivio <stefano.brivio@polimi.it>,
	Network Development <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	b43-dev <b43-dev@lists.infradead.org>
To: nick <xerofoify@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54793E4E.7050602@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/IwltwmK3kbFqBgFDBLIx14S
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Fri, 28 Nov 2014 22:32:30 -0500
nick <xerofoify@gmail.com> wrote:

> I don't have hardware for this driver on me, so I didn't test it. However=
 this seems to=20
> be correct from my reading of the code around this function and other loc=
king related
> to this driver.

=46rom the current docs:

>  * @set_tim: Set TIM bit. mac80211 calls this function when a TIM bit
>  *      must be set or cleared for a given STA. Must be atomic.

So it is not allowed to lock a mutex here.

--=20
Michael

--Sig_/IwltwmK3kbFqBgFDBLIx14S
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJUeYpEAAoJEPUyvh2QjYsOLW0P/22FEoXAnALRPQwJY5SNn3bb
Oop1nbVSvgoS55bid5NFtCdEQHDYXMfbXUBwgggrNlW2v24fRrGpJNRLkD1TBFzY
qBYS/d9eZ3ov4pqOPuIfsDv1ZLNGysurqNh5I0O1HdrIK/0mdH4njmZcU+d9VIYW
xwlk2p4W+F4oiIfc52oC6Vi0V/fBmOiI6uER7woeM51/c1TgVo9h49g1LD/PxYAY
PEGJsBEz5yHa6gouHrOkNM9GgpwWL+MZLR4oaar1bLROK2uQaaOeTaqFoecNn6Tt
rMtsTw4JSJEk4I3MFiHY45yEmAx4OomwtNHK5p2hVOR9oyXwz2x/yak7HdcbSJ4W
yv2YjMZCv2XwG34mOuIoWd+AR38y9dDESe91n3cTohvJx+6N2CJhafVzejZ9svwK
A/a3Wo05uEwj6q5gqNgtGNe8mWdq+GmMdhYDpPbqMxt295tytH7TnbzMhZZwsnNP
J8eT0pG3/fGD1FRFegVIU7ofKtQjbp6jY6wxHfrajt/w3ZlImhvd4YEO35M9oxzP
CT49vG6Hr9hKaDxWoBzlHYyM0tLvq2DeRtmvHrKCismy9zu/5vYdDyh6f50e3auL
RTgShyTTdLPr23idRcc1IejycYOYq5/8uXNEr3aV8/c81SrH30a5mBaZBFl/0lmg
DmOnwp1Ph3r6cUBEeRR8
=XM39
-----END PGP SIGNATURE-----

--Sig_/IwltwmK3kbFqBgFDBLIx14S--
