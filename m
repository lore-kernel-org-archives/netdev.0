From: Maximilian Engelhardt <maxi@daemonizer.de>
Subject: Re: Kernel crash after using new Intel NIC (igb)
Date: Wed, 27 Apr 2011 13:51:59 +0200
Message-ID: <201104271352.00601.maxi@daemonizer.de>
References: <201104250033.03401.maxi@daemonizer.de> <1303878240.2699.41.camel@edumazet-laptop> <1303878771.2699.44.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart4929018.egx1Hc6T0B";
  protocol="application/pgp-signature";
  micalg=pgp-sha512
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	StuStaNet Vorstand <vorstand@stusta.mhn.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1303878771.2699.44.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart4929018.egx1Hc6T0B
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

Hello Eric,

On Wednesday 27 April 2011 06:32:51 Eric Dumazet wrote:
> Le mercredi 27 avril 2011 =C3=A0 06:24 +0200, Eric Dumazet a =C3=A9crit :
> > We had similar reports in the past that disappeared when adding
> > "slab_nomerge" to boot parameters. We suspect a memory corruption from
> > another part of kernel on 64bytes kmemcache objects.
> >=20
> > In 2.6.37, inetpeer code uses 64bytes objects. Using slab_nomerge and
> > SLUB allocator (as you already do), makes sure inetpeer kmemcache wont
> > be shared by other 64bytes objects in kernel.
>=20
> Of course, the right option name is slub_nomerge
>=20
> vi +2293 Documentation/kernel-parameters.txt
>=20
>         slub_nomerge    [MM, SLUB]
>                         Disable merging of slabs with similar size. May be
>                         necessary if there is some reason to distinguish
>                         allocs to different slabs. Debug options disable
>                         merging on their own.
>                         For more information see Documentation/vm/slub.tx=
t.

thank you for this information. I updated the kernel of the affected server=
 to=20
version 2.6.38.4 yesterday. I'll report when there are still crashes, but i=
t=20
might take a while, as in the past they only happened within the interval o=
f=20
weeks to month.

Greetings,
Maxi

--nextPart4929018.egx1Hc6T0B
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJNuANgAAoJEIHqZH0kK9IVhI4P/AjlzQ00sMy9YNrayhfa3I7n
A2pSPvZ4S22TeGpdiHrmRxQKnSR3jpk2C7ukDcNcsnY3hz5WUcqEc58FHYfp/elQ
zGHPdo/8xGpsm56TAHA7qJgakRNaeyHcocWEhu8Flbw1TCB8CFkTfU38prUdWLJQ
i7rz/k1A5PlLeJfHMGGvK6oSfC7wP/Eew+sI5kquYn/bddKQMo+sgFttMfhpvvaQ
dkwXtBeZVX5QWP8QztzQiJbv2a+dqCfO4h/fj6NJfPlyifFYgSpC5LW7xFDHqxNM
NSDxhoWfbbV6Tl4CSyTUHdzWU+NGJfJkXe95iWhjUnNmm9d/lMa7hwJdAEtPsQCM
ydTb2YfEcjFe2w81IXoEdq6gS0AbNTsHkWVjfaIszUul9L3IOjijmPXxwWsTEr7n
EfOhjYAMMNolraoA5k30HuJ8K2PiiBdvj7pWvCaEnblWpyG6q+2ZXgGOeL3GsTMm
BUZLgIWlNJ8Y2QzQBuLPmk8sGSGwaPa/sbMCSAPO57hF7wkWup3IkKqzab1AqR52
OwWc1I13UEmCaorLAKYg+ZjKvJ0RytZP91WvJLs1fJcFiFZDkOYGZySHxGySz3HD
b0IKHaQN2mS49YtKNiMFgHJfPu0Vxs+nu+lvxEn2sMVteWABjX5q9zzlsbr/ARKB
8oOuAjLq779KiezcXniV
=Ydae
-----END PGP SIGNATURE-----

--nextPart4929018.egx1Hc6T0B--
