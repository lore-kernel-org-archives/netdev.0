From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: Re: [PATCH 04/10] batman-adv: export compatibility
 version via debugfs
Date: Mon, 19 Nov 2012 22:09:56 +0100
Message-ID: <20121119210955.GA3129@ritirata.org>
References: <1353313451-2930-5-git-send-email-ordex@autistici.org>
 <1353351150.4156.4.camel@bwh-desktop.uk.solarflarecom.com>
 <5268262.CIrZ93ERtB@bentobox>
 <20121119.144745.1093556126398582629.davem@davemloft.net>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature"; boundary="k1lZvvs/B4yU6o8G"
Cc: bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org, lindner_marek-LWAfsSFWpa4@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121119.144745.1093556126398582629.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org


--k1lZvvs/B4yU6o8G
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Nov 19, 2012 at 02:47:45PM -0500, David Miller wrote:
> From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
> Date: Mon, 19 Nov 2012 20:29:07 +0100
>=20
> > On Monday 19 November 2012 18:52:30 Ben Hutchings wrote:
> >> On Mon, 2012-11-19 at 09:24 +0100, Antonio Quartulli wrote:
> >> > Different versions of the batman-adv module may use the same compati=
bility
> >> > version, but this is not understandable at runtime (the only way is =
to
> >> > parse the kernel log and fetch the batman-adv advertisement message =
on
> >> > loading). The user may want to know whether two nodes using different
> >> > versions can communicate or not. For this purpose the module has to
> >> > export this value through debugfs.
> >> [...]
> >>=20
> >> I do hope that you're not planning to use unstable debugfs interfaces
> >> indefinitely.
> >=20
> > Why are you refering to the adding of an file as "incompatible" debugfs=
=20
> > interface? I would call it additional information. And the rest of the =
commit=20
> > message is talking about *possible* protocol incompatibilies of the net=
work=20
> > protocol (which caused this uncontrolled erruption of anger in a networ=
k=20
> > maintainer).
>=20
> Debugfs files aren't where you store information that userspace actually
> uses in normal situations.
>=20
> It's for developer debug, to expose internals that otherwise have no
> business being part of the user visible interfaces.

Ok, you are right. As you already stated, I do see two problems here:
1) debugfs not used properly (this information is not really for "devs")
2) this compatibility version export is like the claim: "compatibility is b=
roken
   everyday". But actually this is not what we really wanted.

This patch simply came from a feature request raised by a user of ours. As =
Sven
pointed out, we have seen it just as "more information available for network
debugging" and we (in particular me) didn't think about the fact that having
such a patch was against the "stabilisation" process that we are following =
(we
discussed about this process during the last pull request, so you already k=
now
that we are already going towards this direction).

David, Ben, if you agree I would remove this patch and repost the pull requ=
est.


Regards,

--=20
Antonio Quartulli

=2E.each of us alone is worth nothing..
Ernesto "Che" Guevara

--k1lZvvs/B4yU6o8G
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iEYEARECAAYFAlCqoCMACgkQpGgxIkP9cwfuSgCfWdmoWU40GG44YPohSM3VRErc
xFkAn1bvqqcJSm0A4cOFc9dU87fzSagi
=9kq8
-----END PGP SIGNATURE-----

--k1lZvvs/B4yU6o8G--
