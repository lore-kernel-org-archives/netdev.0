From: Rik van Riel <riel@redhat.com>
Subject: Re: [RFC PATCH 0/2] net: threadable napi poll loop
Date: Tue, 10 May 2016 18:02:33 -0400
Message-ID: <1462917753.16365.15.camel@redhat.com>
References: <cover.1462886866.git.pabeni@redhat.com>
	 <1462890590.23934.68.camel@edumazet-glaptop3.roam.corp.google.com>
	 <90f3db8c-c30c-b204-576a-454939ac93ce@stressinduktion.org>
	 <CANn89i+YKrVOgfFwW-2psfCzq5_YLdmbV06-H-1FCOwXdMBuzQ@mail.gmail.com>
	 <1462915900.23934.99.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1462916121.16365.14.camel@redhat.com>
	 <1462917217.23934.101.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-DoNbjaDuYhSFAWHdNQFO"
Cc: Eric Dumazet <edumazet@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Paolo Abeni <pabeni@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Tom Herbert <tom@herbertland.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462917217.23934.101.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-DoNbjaDuYhSFAWHdNQFO
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-05-10 at 14:53 -0700, Eric Dumazet wrote:
> On Tue, 2016-05-10 at 17:35 -0400, Rik van Riel wrote:
>=20
> >=20
> > You might need another one of these in invoke_softirq()
> >=20
> Excellent.
>=20
> I gave it a quick try (without your suggestion), and host seems to
> survive a stress test.
>=20
> Of course we do have to fix these problems :
>=20
> [=C2=A0=C2=A0147.781629] NOHZ: local_softirq_pending 48
> [=C2=A0=C2=A0147.785546] NOHZ: local_softirq_pending 48
> [=C2=A0=C2=A0147.788344] NOHZ: local_softirq_pending 48
> [=C2=A0=C2=A0147.788992] NOHZ: local_softirq_pending 48
> [=C2=A0=C2=A0147.790943] NOHZ: local_softirq_pending 48
> [=C2=A0=C2=A0147.791232] NOHZ: local_softirq_pending 24a
> [=C2=A0=C2=A0147.791258] NOHZ: local_softirq_pending 48
> [=C2=A0=C2=A0147.791366] NOHZ: local_softirq_pending 48
> [=C2=A0=C2=A0147.792118] NOHZ: local_softirq_pending 48
> [=C2=A0=C2=A0147.793428] NOHZ: local_softirq_pending 48

As long as ksoftirqd is running, that should not be
an actual problem, just a false positive.

--=20
All Rights Reversed.


--=-DoNbjaDuYhSFAWHdNQFO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXMlp5AAoJEM553pKExN6Dr/IIALz4Yd99H6IlqiDMd4gwcBD0
mKD8kXb0YYkao48PbWPrOqNzK7CSbYltgN2vu0yvg4MVb+gRD3/Kv8UKtR+Ot+C4
9DG4Q+2AiJ9Y0f7dkR+Cx0q7aKPwSzT4KjXAf0j5i257mAyHxGkP7hEXyQJztotT
h24UW07Olbn9CcoGsd6eDgWaVZ8SRsN3aYeVHWs7jFjhCfls6Ul7xyG5aKdugUaK
Dt+fuMTX9GVacjUVQQSErqvzsqZkgaex7SRXlYA4423PVogMkEyeO4PJWL1dCT7X
Uf+pA3DAoManhyz/X68se8du+zgS0OHxR8GP1ZxlYDUx0ljFHdJ5VA18qa1IMh4=
=axQ7
-----END PGP SIGNATURE-----

--=-DoNbjaDuYhSFAWHdNQFO--
