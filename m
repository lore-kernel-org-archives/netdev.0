From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: pull request: wireless-2.6 2008-08-26
Date: Wed, 27 Aug 2008 12:10:28 +0200
Message-ID: <1219831828.3891.3.camel@johannes.berg>
References: <20080827013009.GA15781@tuxdriver.com>
	 <1ba2fa240808270038r24d5eeb9l36fd70ef5ae904f5@mail.gmail.com>
	 <20080827.014041.230100807.davem@davemloft.net>
	 <1219835410.5359.24.camel@californication>
	 <1ba2fa240808270305m7f505efak9fd0d36d5db09a1e@mail.gmail.com>
	 (sfid-20080827_120532_961620_59DBABFA)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-LLjGWuXI6+0CCO3/QRhf"
Cc: Marcel Holtmann <holtmann@linux.intel.com>,
	David Miller <davem@davemloft.net>, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Tomas Winkler <tomasw@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755734AbYH0KLJ@vger.kernel.org>
In-Reply-To: <1ba2fa240808270305m7f505efak9fd0d36d5db09a1e@mail.gmail.com> (sfid-20080827_120532_961620_59DBABFA)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-LLjGWuXI6+0CCO3/QRhf
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2008-08-27 at 13:05 +0300, Tomas Winkler wrote:

> There is a central problem here, since I cannot really adjust driver
> development progress from obvious reason with Linux merging window.
> Upstream kernel is unfortunately not the only customer I report to. So
> actually stable versions got half backed drivers depending on some
> arbitrary time cut from my (selfish) development point of view.

FWIW, many people including myself think you should work the other way
around, that is develop things in the mainline/wireless-testing tree
rather than developing a stable version internally and then dumping a
big pile of patches whenever it's convenient for you. IOW, we think you
should use Linux upstream as your development tree and then branch off
of that for the internal stabilisation trees you need for other
customers, rather than having some sort of internal development tree and
branching out Linux upstream as you appear to work.

That would also avoid the nasty surprises you've gotten a few times
where other people managed to get patches to iwlwifi drivers into the
Linux tree without you noticing.

johannes

--=-LLjGWuXI6+0CCO3/QRhf
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJItSgQAAoJEKVg1VMiehFYuJYP/1ItS9+xEGT6O7Dgm2eathlO
K/SaRUm7J1fTS1b1WS5ti5onPGur0p5XwsSKetIkV7buncabtes9vyEQTPBabxya
5tIVTqimnVjw+PacbAER0kKTNcwynYu3hF+50N4EaytisR37rq1SOGLxJUH8KduJ
E2rHcaosXtZe/ZuO5X3GVfpd8z5uyanMKqPbDt050iACqknXaz2i/tKNt4Lrc7Pz
eoDlz7O8gj3/SlXmDL5iq1l9Mtr/k1RuM4dxVN26KfbBgmdg9laf6dgsPCa29Dnj
NM5BbDnnP79Wt1f61NZ530MJJeQd3JFJHdCjtMmC1V+7wM06IqrjeM9pi4wV2CKw
6qnGIqLnZ4pd2w11RWVdPmOyRm7p8a4Gn5ryPvAxpNzD6oikPaqaB8W5JAUbu6PQ
4vAIdDnmZIS1EvtSr3UzYIRNOFeAGCZj8hBmnSfj4m11DWN8jWZYYmh+4tAlm6Jq
KwSAHfOHJksexa6g6/KnCSFshP7Y2ZwGcPo613peVqCjahVun11MERi/zpk7c1rS
QGjpMf6lYCIClJgH3m0dEdB7tRqowRMwqacn+vvm/w4oQoZkOHwqSPZy8mSWva2v
1iMD97VFbgDhqmjZ5VzRIZtOByn5rbeh12Y0PLkRdipHp8MVCcaDv9Z8qw9nrDuq
Zc+aIMh34yfLOJa4EhiH
=KkbX
-----END PGP SIGNATURE-----

--=-LLjGWuXI6+0CCO3/QRhf--
