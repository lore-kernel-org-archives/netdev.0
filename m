From: Johannes Truschnigg <johannes@truschnigg.info>
Subject: Re: PROBLEM: Silent data corruption when using sendfile()
Date: Sat, 14 Jul 2012 12:13:21 +0200
Message-ID: <20120714101321.GA26329@vault.local>
References: <20120713171835.GA26052@vault.local>
 <CAJd=RBAntSubDBbJ292SzeoN4hTwBQ_Q23jt+Y6i-+vfrQ5EHQ@mail.gmail.com>
 <1342254042.3265.9017.camel@edumazet-glaptop>
 <20120714083136.GO16256@1wt.eu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="G4iJoqBmSsgzjUCe"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org,
	Linux-Netdev <netdev@vger.kernel.org>
To: Willy Tarreau <w@1wt.eu>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120714083136.GO16256@1wt.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--G4iJoqBmSsgzjUCe
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Jul 14, 2012 at 10:31:36AM +0200, Willy Tarreau wrote:
> > Please Johannes could you try latest kernel tree ?
>=20
> It would be useful, especially given the amount of changes you performed
> in this area in latest version, it could be very possible that this new
> bug got fixed as a side effect !

I upgraded to 3.4.4 (identical config as the 3.4.0 build I've been running)
and what can I say - the problem really seems to have disappeared. I perfor=
med
about 3700 iterations of my previos tests over the night, and the data alwa=
ys
turned out to be OK, not a single byte turned out kaput!

I wish I would have tested that earlier, and spared you the noise... well,
maybe someone who runs into a similar problem in the future will have this
discovery save her/him some time and headaches and make her/him just upgrade
kernels :)

Thanks a lot for your polite and quick responses!

--=20
with best regards:
- Johannes Truschnigg ( johannes@truschnigg.info )

www:   http://johannes.truschnigg.info/
phone: +43 650 2 133337
xmpp:  johannes@truschnigg.info

Please do not bother me with HTML-email or attachments. Thank you.

--G4iJoqBmSsgzjUCe
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAlABRkEACgkQnnUApj8OcoLtmQCfcdn0Om7SnCUO6R2WhXV/E0EC
Z+EAoJe3gQApITV72Md9SBrvQgghjHQ+
=IaNX
-----END PGP SIGNATURE-----

--G4iJoqBmSsgzjUCe--
