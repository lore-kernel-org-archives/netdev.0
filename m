From: mcgrof@ruslug.rutgers.edu (Luis R. Rodriguez)
Subject: Re: Prism54 AP WPA using Hostap and WDS
Date: Fri, 5 Nov 2004 11:20:37 -0500
Message-ID: <20041105162037.GN388@ruslug.rutgers.edu>
References: <20041104032219.GU388@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2013834491=="
Cc: Netdev <netdev@oss.sgi.com>, Jouni Malinen <jkmaline@cc.hut.fi>
Return-path: <prism54-devel-bounces@prism54.org>
To: prism54-devel@prism54.org
In-Reply-To: <20041104032219.GU388@ruslug.rutgers.edu>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Mime-version: 1.0
Sender: prism54-devel-bounces@prism54.org
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org


--===============2013834491==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="QDd5rp1wjxlDmy9q"
Content-Disposition: inline


--QDd5rp1wjxlDmy9q
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Nov 03, 2004 at 10:22:19PM -0500, Luis R. Rodriguez wrote:
>=20
> I'd like to announce we've received patches to allow for AP WPA
> using hostap and complete WDS support. I'd like to thank Bell Kin from
> PEK Inc. for contributing this. I'll be reviewing the code now and
> integrating what needs to go into CVS.
>=20
> WPA STA support is still there -- what can I say, I'm stuck. I believe I
> have added most of what needs to be added to the driver for its support
> but at this point am having trouble getting the device to work
> appropritately. I do believe companies out there do have WPA STA support
> for their FullMAC chipsets. I wanted to ask for their support in
> reviewing what we have to see if we can finally get this through.
>=20
> Thanks,
>=20
> 	Luis

Great news,

I have reviewed, cleaned up and committed Bell Kin's patches into CVS.
Prism54 AP WPA (Version 1) support and WDS support is now
complete. I've updated the README and there two new sections:

Access Point WPA support (NEW) (requires hostapd)
Access Point WDS Support (NEW)

I did not have time or a box available to test the code (even to
compile). Please help with this. Please read the documentation, and test.=
=20
If you find something broken please e-mail prism54-devel and if possible=20
send patches which fixes what's broken even if its documentation.

After this has been tested we then can send patches upstream to netdev
for kernel inclusion.

Please note that Prism54 client/STA suppport has been added but its not
yet working. We need help with this from experienced companies that have
used the FullMAC and enabled STA WPA support.

---
Left on our TODO list are:

* fix WPA STA support
* move to netif_msg, away from our nasty debug system

I say let's work hard on these two and push a new driver release.
---

Thanks once again to Bell Kin for from PEK Inc for his contributions.

	Luis

--=20
GnuPG Key fingerprint =3D 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E

--QDd5rp1wjxlDmy9q
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFBi6hVat1JN+IKUl4RAm2bAJ9UVWYY+5hTpHvVYsZ8L+8kzBY3ggCfdiss
DTta2Avhs3ajwOPtSK+HVF4=
=Zorm
-----END PGP SIGNATURE-----

--QDd5rp1wjxlDmy9q--

--===============2013834491==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--===============2013834491==--
