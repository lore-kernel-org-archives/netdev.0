From: Sven Eckelmann <sven@narfation.org>
Subject: Re: net: add seq_before/seq_after functions
Date: Thu, 19 May 2011 11:21:21 +0200
Message-ID: <201105191121.23888.sven@narfation.org>
References: <1305722319-8315-1-git-send-email-ordex@autistici.org> <201105191054.34912.sven@narfation.org> <20110519.050824.838971689287732822.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart10883730.ts7hrPEUfv";
  protocol="application/pgp-signature";
  micalg=pgp-sha512
Content-Transfer-Encoding: 7bit
Cc: ordex@autistici.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, paulus@samba.org, linux-ppp@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110519.050824.838971689287732822.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart10883730.ts7hrPEUfv
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

On Thursday 19 May 2011 11:08:24 David Miller wrote:
> From: Sven Eckelmann <sven@narfation.org>
> Date: Thu, 19 May 2011 10:54:32 +0200
>=20
> > On Wednesday 18 May 2011 14:38:39 Antonio Quartulli wrote:
> >> Introduce two operations to handle comparison between packet sequence
> >> numbers taking into account overflow/wraparound. Batman-adv uses
> >> these functions already to check for successor packet even in case of
> >> overflow.
> >=20
> > Thanks for your efforts to bring that to the kernel. But when you prepa=
re
> > a patch then you have to add a signoff. And also David S. Miller is the
> > maintainer for this header - it would be interesting to ask him first
> > when we want to change that file.
>=20
> Well it makes no sense to add these interfaces until we see an
> upstream submission of code which will actually use it.
>=20
> Also I'm skeptical that such generic sounding interfaces make
> sense when it appears to me that these are protocol specific
> sequence number tests so probably belong in whatever protocol
> is upcoming which will use these interfaces.
>=20
> Again, this is why we want to see the code that's going to use
> these new routines before we can seriously consider adding them
> at all.

This is currently used by vis.c in net/batman-adv and could also be used by=
=20
ppp-generic.c (with my changes of course). And it is planned to be used by=
=20
transtable.c in net/batman-adv. The idea was to propose this to linux-
kernel/netdev before we move it to a place were only batman-adv can use it=
=20
(the current situation is that vis.c in batman-adv can only use it).

It is ok that you say that it should be batman-adv specific - we only wante=
d=20
to ask first.

Thanks,
	Sven

--nextPart10883730.ts7hrPEUfv
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJN1OESAAoJEF2HCgfBJntGI98P/3Kz6biulUZuYblnQbLw9qt1
k3u6dabcCkq3u/llGMLZ2OcgaSnsLlCYfhZkZ/hS6UOnqbfhDEdRgn+nyPoH4UhV
keDjmW0tp6y6rBoNehyaK1me3RizvYeieOuVPwABoPkwSRt1fJTND8junde1Fl+U
27S2QD3LmsLvwvxuE6Im9Or2lrKEU0MBCG0aCnPTSKBCgdLR+ZzS7MueJB3u+9KR
4HkY0qZVzhyK9Mv/ySHENgS5EbK1nNzfNuESfF9lNSLhjZadZJ0PA7qludIKxZgv
vEtuKJ561gpj2AIx0jHehq4Kssjf4ceV6dHSzwC5KVADT3gy9xZU83LqYp0HOfT3
1xYd8PolzyAiurwHEpwtPasxX7+wv3q2WWqk5dd0smHQxF9DDoIHyLSGuWkI0vhd
4L0d77S+Xxc5JMlKre3bK6rM5UgcfT+S6+Qb2ottv4xfJMspP4wWYumlyPIWVuY5
wuxisG/5Q6Skvie5uMmC9ubGLW8bze3dIHbf62BnW9bek2FZS614WAOEFkrbHye7
yd5uNqe5QNeADYopInDUay1y7rrRR5SZmCv9D1vE8025uZKFlV2XvejaUJtdjH/3
G+UIuHGKIQ4zn0qSL54d9A1Ygfx9P5OF29BH0JFY+xGN1jIcqcgbC/W5vZi0J5Do
R4KI7hPiKljQsVS0QasO
=quch
-----END PGP SIGNATURE-----

--nextPart10883730.ts7hrPEUfv--
