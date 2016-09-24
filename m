From: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Subject: Re: [RFC v2 00/10] Landlock LSM: Unprivileged sandboxing
Date: Sat, 24 Sep 2016 09:45:25 +0200
Message-ID: <20160924074525.GA28371@amd>
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <20160915091902.GA13132@amd>
 <57E16D07.4050301@digikod.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="IS0zKkzwUGydFO0o"
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
        Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
        Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>,
        Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
        Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>,
        David Drysdale <drysdale-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Elena Reshetova <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        James Morris <james.l.morris-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        Paul Moore <pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>,
        "Serge E . Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>,
        Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <57E16D07.4050301-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--IS0zKkzwUGydFO0o
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue 2016-09-20 19:08:23, Micka=EBl Sala=FCn wrote:
>=20
> On 15/09/2016 11:19, Pavel Machek wrote:
> > Hi!
> >=20
> >> This series is a proof of concept to fill some missing part of seccomp=
 as the
> >> ability to check syscall argument pointers or creating more dynamic se=
curity
> >> policies. The goal of this new stackable Linux Security Module (LSM) c=
alled
> >> Landlock is to allow any process, including unprivileged ones, to crea=
te
> >> powerful security sandboxes comparable to the Seatbelt/XNU Sandbox or =
the
> >> OpenBSD Pledge. This kind of sandbox help to mitigate the security imp=
act of
> >> bugs or unexpected/malicious behaviors in userland applications.
> >>
> >> The first RFC [1] was focused on extending seccomp while staying at th=
e syscall
> >> level. This brought a working PoC but with some (mitigated) ToCToU race
> >> conditions due to the seccomp ptrace hole (now fixed) and the non-atom=
ic
> >> syscall argument evaluation (hence the LSM hooks).
> >=20
> > Long and nice description follows. Should it go to Documentation/
> > somewhere?
> >=20
> > Because some documentation would be useful...
>=20
> Right, but I was looking for feedback before investing in documentation. =
:)

Heh. And I was hoping to learn what I'm reviewing. Too bad :-).

								Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--IS0zKkzwUGydFO0o
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlfmLxUACgkQMOfwapXb+vIhUwCeJRBd+yxgp5b6dajyXx7AqeXp
NpoAnj5y4eKIbwut7GxzUIFQBVxKg8q/
=1Isn
-----END PGP SIGNATURE-----

--IS0zKkzwUGydFO0o--
