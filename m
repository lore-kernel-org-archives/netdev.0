From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH v2 net 1/2] drivers/net: Disable UFO through virtio
Date: Thu, 30 Oct 2014 22:20:02 +0000
Message-ID: <1414707602.16849.70.camel@decadent.org.uk>
References: <1414693592.16849.61.camel@decadent.org.uk>
	<1414693632.16849.62.camel@decadent.org.uk>
	<1414694849.15352.3.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4443335699894482832=="
Cc: netdev@vger.kernel.org, Hannes Frederic Sowa <hannes@stressinduktion.org>,
	virtualization@lists.linux-foundation.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1414694849.15352.3.camel@edumazet-glaptop2.roam.corp.google.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org


--===============4443335699894482832==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-qc+puuwzD+2wgq2cHdXT"


--=-qc+puuwzD+2wgq2cHdXT
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-10-30 at 11:47 -0700, Eric Dumazet wrote:
> On Thu, 2014-10-30 at 18:27 +0000, Ben Hutchings wrote:
>=20
>=20
> > +		{
> > +			static bool warned;
> > +
> > +			if (!warned) {
> > +				warned =3D true;
> > +				netdev_warn(tun->dev,
> > +					    "%s: using disabled UFO feature; please fix this program\n",
> > +					    current->comm);
> > +			}
> >
>=20
> It might be time to add netdev_warn_once() ;)

Could do.  I'm trying to make small fixes that are suitable for stable.

> Alternatively, you could use=20
> 	pr_warn_once("%s: using disabled UFO feature; please fix this program\n"=
,
> 		     tun->dev->name, current->comm);

That's missing a "%s: ", but yes that would also work.

Ben.

--=20
Ben Hutchings
The program is absolutely right; therefore, the computer must be wrong.

--=-qc+puuwzD+2wgq2cHdXT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVFK5l+e/yOyVhhEJAQqjzA//TXb1rN4MzFmENQ0GOhIwO9D6Fxb/8UuR
ioVfFX37pU7MZSEAbRG7goaK303qNMcfg9dZqFGu1Zwny1hkfewWTE/ODNdhkflL
Eu52XuAzSkB2D8LpwX9HCfvHeuWwiCLpeyBrxyR8QdayjxVEJ+ACRAk3BNAXAOpY
Z+LhGXH7emoOC4urt8Qs93D/V3nXQKahqTAixlTCwdvmkZIQw5ndh9amfcoLIDFp
LG/Eg/8czgpFwkg3nASuCvSjxG9lwaQltTAB5nS32COVtQ80ePMnQI2jkVSM4jpp
x1CxXZo6DEqnffe1Rqx8/yWUcGRzH4N6Sy06bXhatils6WhefkuS0g0lrHFCTSRf
PevZjW40bM0fDT2hSgqw2pK0MlN2Apdfe0QvZKU+73fIlp4sLzx/wAlReaFf1U+V
s64JR+WZDmRAUsnUMMxTGxDq+QQXXZqsLNZ0tVFaF1W9nss3wWTk18lOPa5JJIwH
vT8Z111katoPq4qnUVZNL3pK3TMW2/jpcKhTwE93n+/GX2mvHzH+amb2fJpsqSki
qZxgQW9NYPCW7G7eAoxcDh4dECqsKZkMENHhL1V2R04OHE+k8OAouDGUWhrEVXu0
7Siez3BqgSW0zcpwmbqAu+oIMavrZlNb8Fa0YE4rGfetPDJe8A/7MLzLRC1nkRPj
2R/ZGo98Ick=
=qnNN
-----END PGP SIGNATURE-----

--=-qc+puuwzD+2wgq2cHdXT--

--===============4443335699894482832==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============4443335699894482832==--
