From: Johannes Truschnigg <johannes@truschnigg.info>
Subject: Re: PROBLEM: Silent data corruption when using sendfile()
Date: Sat, 14 Jul 2012 19:09:53 +0200
Message-ID: <20120714170953.GA26406@vault.local>
References: <20120713171835.GA26052@vault.local>
 <CAJd=RBAntSubDBbJ292SzeoN4hTwBQ_Q23jt+Y6i-+vfrQ5EHQ@mail.gmail.com>
 <1342254042.3265.9017.camel@edumazet-glaptop>
 <20120714083136.GO16256@1wt.eu>
 <20120714101321.GA26329@vault.local>
 <1342262004.3265.9279.camel@edumazet-glaptop>
 <20120714104441.GP16256@1wt.eu>
 <1342263967.3265.9347.camel@edumazet-glaptop>
 <20120714131540.GQ16256@1wt.eu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="huq684BweRXVnRxX"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org,
	Linux-Netdev <netdev@vger.kernel.org>
To: Willy Tarreau <w@1wt.eu>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120714131540.GQ16256@1wt.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--huq684BweRXVnRxX
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Jul 14, 2012 at 03:15:40PM +0200, Willy Tarreau wrote:
> On Sat, Jul 14, 2012 at 01:06:07PM +0200, Eric Dumazet wrote:
> [...]
> > Hmmm, this is supposed to fix a bug introduced in 3.4, no ?
> >=20
> > So 3.3 kernel should work well ?
>=20
> You're right indeed. So maybe it's not the same bug. Or maybe Johannes
> was affected by two different bugs in both versions, since Thorsten's
> report seems to point the finger at the same bug.
>=20
> Johannes, are you certain that you were having the exact same issue
> with 3.3 ?

I still have the Linux 3.3-series kernel image around that I _think_ I first
saw the problem occur with. I'll try to reproduce the problem with that
kernel, but I cannot promise that results will be ready before Tuesday. I'll
keep you posted!

--=20
with best regards:
- Johannes Truschnigg ( johannes@truschnigg.info )

www:   http://johannes.truschnigg.info/
phone: +43 650 2 133337
xmpp:  johannes@truschnigg.info

Please do not bother me with HTML-email or attachments. Thank you.

--huq684BweRXVnRxX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAlABp+EACgkQnnUApj8OcoKbXQCeO1k6mw/IFfWBkBMhHpbh+AYV
HlMAn1CeGVFDNf44HCbYmppKyMIMVR7a
=lKDD
-----END PGP SIGNATURE-----

--huq684BweRXVnRxX--
