From: Antonio Quartulli <ordex@autistici.org>
Subject: Re: [B.A.T.M.A.N.] net, batman: lockdep circular dependency warning
Date: Wed, 5 Dec 2012 22:03:13 +0100
Message-ID: <20121205210313.GK27828@ritirata.org>
References: <20121205153307.GA30466@pandem0nium>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="KbI68ipL6xvRMBYq"
Cc: netdev@vger.kernel.org, Sasha Levin <sasha.levin@oracle.com>
To: The list for a Better Approach To Mobile Ad-hoc
	 Networking <b.a.t.m.a.n@lists.open-mesh.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:38258 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754309Ab2LEVEH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 16:04:07 -0500
Content-Disposition: inline
In-Reply-To: <20121205153307.GA30466@pandem0nium>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--KbI68ipL6xvRMBYq
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

On Wed, Dec 05, 2012 at 04:33:08PM +0100, Simon Wunderlich wrote:
> Hey Sven,
> >=20
> > 1. Remove the sysfs interface to attach/detach net_devices (which
> >    destroys/creates batman-adv devices)
> >=20
> >    This is not really backward compatible and therefore not really acce=
ptable.
> >    Marek Lindner and Simon Wunderlich are also against forcing users to
> >    require special tools to add/configure batman-adv devices (even batc=
tl, ip
> >    and so on).
> >=20
>=20
> Yeah, at least I think we should keep what we have for now and fix it bef=
ore
> moving to the next interface. It has its merits I would like to keep, hav=
ing
> text output is one of them. :)

I agree on this. Not because of the nice text output, but rather because it=
 is
better to first fix this deadlock in the current interface (which might mean
fixing old stable releases) and when we include the new feature.


[...]

> > 5. Add a workaround solution and promote the use of the standard interf=
ace
> >=20
> >    So, the basic problem is the s_active mutex locked by the sysfs inte=
rface.
> >    An idea is to postpone the part which needs the rtnl_mutex to a late=
r time.
> >    This has obviously the problem that we cannot return an error code t=
o the
> >    caller when the device creation failed in the postponed part. This p=
roblem
> >    can reduced slightly be moving only the unregister part, but now I'l=
l leave
> >    this out for simplicity of the description.
>=20
> We probably won't need the return code anyway - usually it should never f=
ail,
> and if it does we don't handle it now too.=20
>=20
> >=20
> >    A possible implementation would create a work_struct and add it to
> >    batadv_event_workqueue. This work item has to contain all informatio=
n given
> >    by the user (which hardif, name of the batman-adv device).
>=20
> Sounds good.
>=20
> >=20
> >    Simon Wunderlich already disliked this workaround, but Antonio Quart=
ulli
> >    tried to encourage an RFC implementation. I've prefered a textual
> >    description rather than a patch missing explanations of the other
> >    alternatives.
>=20
> Well, actually that doesn't sound so bad - I currently don't have an over=
view
> of how "big" this change would be - this one was one concern, the return =
code was
> another but it appears that this isn't a problem. If we don't add too muc=
h bloat
> this one would probably the best alternative. At least as long as rtnl_un=
lock()
> behaves like this. :)
>=20
> What do others think?
>=20

I like this approach too.
It looks clean and it doesn't affect the rest of the net code.
I think we should put some effort in this and try to come up with a patch s=
oon.

Thank you for your comments.

Cheers,



--=20
Antonio Quartulli

=2E.each of us alone is worth nothing..
Ernesto "Che" Guevara

--KbI68ipL6xvRMBYq
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBAgAGBQJQv7aRAAoJEADl0hg6qKeOc/cP/inTkUH+LvwKzwz/ypnh3+ZU
U7nPC0jA125Xn/MZDARuIgqWUo1iKFoh4EicLaF7lTgYEyM1LWVewLwZDlB+Klpg
yvnOnI8tn4CkPpN+BiUumndtCsL8LS/4hCqkFP55TZQDaPBRDjwn6r/lwgQbldzr
1o4Kf7OvsC0L948rKHoeXoeRfi7RtqWpifHkWDaqZuaj0lMc5iKZUulqJ71hTAhx
RPEC64E4t7QkkmFER6r/XQ6ykBFdKwLK+zx135V3WlnYiLPccGKJ/Opb/HwQQ3hp
ojWPQrydds3B7R5EnGPHKwi87Wd7PNYA76PgUo8YV2mKpxnmxI4XVIn1ePUKeZnn
i3npRmmB3Nt3ecioNb/YI98++JQWRsctHiGfdIENhvM7KM4jaAOFaMA/s4rEOWL5
nI5yG6Wb3wOLfRrtfrqqfOKjxTsyk1FDY6YJLfbUH3v+IhEj+w/Q6cNXbhezCJgy
oCRLcqq3DpfE6A6gn81EvsCzB7UgUE/HIP5knFY9+ypl4YJ9LXeIr4Z5C+LbwH3k
fAnoq727bvP0ovAly7vkJib5REP7SqNE5BzACd0PAHNeuwMANNk6tn28cmo4Wkls
qFoV+dakg5pTU/+BdyH04zS1JBjhtwNBlRPXcxRVHGIOKfEURrsbS5m35jn/awkm
e9G/HdFXDWpfg0/8bx4P
=zq4/
-----END PGP SIGNATURE-----

--KbI68ipL6xvRMBYq--
