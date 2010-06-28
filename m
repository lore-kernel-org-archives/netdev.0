From: Henning Rogge <hrogge-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: Re: Reviewing batman-adv for net/
Date: Mon, 28 Jun 2010 07:32:12 +0200
Message-ID: <201006280732.17568.hrogge@googlemail.com>
References: <201006260214.06662.sven.eckelmann@gmx.de>
	<20100627222706.GC8285@nuttenaction>
	<201006280115.25518.lindner_marek@yahoo.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart22418923.0Y6NxtKRFt";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Hagen Paul Pfeifer <hagen-GvnIQ6b/HdU@public.gmane.org>,
	Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <201006280115.25518.lindner_marek-LWAfsSFWpa4@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

--nextPart22418923.0Y6NxtKRFt
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

Am Montag 28 Juni 2010, 01:15:23 schrieb Marek Lindner:
> the OLSR as standardized by the IETF is known to be flawed when used
> outside of a simulator (even the IETF Manet people know this - I spoke
> with one of them). We have assembled a few documents explaining some of
> its weaknesses on our website (www.open-mesh.org) but I suggest you get in
> touch with the folks of www.olsr.org. They can go into the details of why
> they don't follow the RFC.
OLSRv1 lacks the support for routing metrics in the IETF RFC document. Most=
 of=20
the research groups began integrating routing metrics later, and OLSRv2 (wh=
ich=20
is worked on at the moment, 2 RFC's done, 1 at IESG, 1 as a draft) will=20
contain specified ways to include a routing metric on a link and how to use=
=20
it. We were talking about the generic metric encoding some weeks ago on the=
=20
MANET WG list.

Using hopcount metric (as described in the RFC 3626) will result in a "wors=
t=20
link first" strategy in wireless networks, because you always optimize for=
=20
long links which will break often.

It's not difficult to integrate a routing metric into OLSRv1, but in the ol=
d=20
OLSRv1 RFC (2003) there it's not specified. We (the olsr.org team) use a=20
custom message format to add metric information to our hello/tc messages, t=
he=20
NRL use a different one for their own metric aware OLSR.

Henning Rogge (olsr.org team)

=2D-=20
1) You can't win.
2) You can't break even.
3) You can't leave the game.
=E2=80=94 The Laws of Thermodynamics, summarized

--nextPart22418923.0Y6NxtKRFt
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.15 (GNU/Linux)

iEYEABECAAYFAkwoM+EACgkQcenvcwAcHWdQQACcCJX6svQ2pz3BI4tuTqHlageW
zXoAn0WLF3D+TRbrAhyXDaFdQVnnHGpQ
=yUiS
-----END PGP SIGNATURE-----

--nextPart22418923.0Y6NxtKRFt--
