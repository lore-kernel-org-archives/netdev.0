From: Jan-Benedict Glaw <jbglaw@lug-owl.de>
Subject: Re: [RFC 2.6.10 1/22] xfrm: Add direction information to xfrm_state
Date: Thu, 30 Dec 2004 10:48:39 +0100
Message-ID: <20041230094839.GX2460@lug-owl.de>
References: <20041230035000.01@ori.thedillows.org> <20041230035000.10@ori.thedillows.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="urKaCNvFwQ8jDQOg"
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: David Dillow <dave@thedillows.org>
Content-Disposition: inline
In-Reply-To: <20041230035000.10@ori.thedillows.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--urKaCNvFwQ8jDQOg
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, 2004-12-30 03:48:34 -0500, David Dillow <dave@thedillows.org>
wrote in message <20041230035000.10@ori.thedillows.org>:
> diff -Nru a/include/net/xfrm.h b/include/net/xfrm.h
> --- a/include/net/xfrm.h	2004-12-30 01:12:08 -05:00
> +++ b/include/net/xfrm.h	2004-12-30 01:12:08 -05:00
> @@ -146,6 +146,9 @@
>  	/* Private data of this transformer, format is opaque,
>  	 * interpreted by xfrm_type methods. */
>  	void			*data;
> +
> +	/* Intended direction of this state, used for offloading */
> +	int			dir;
>  };
> =20
>  enum {
> @@ -157,6 +160,12 @@
>  	XFRM_STATE_DEAD
>  };
> =20
> +enum {
> +	XFRM_STATE_DIR_UNKNOWN,
> +	XFRM_STATE_DIR_IN,
> +	XFRM_STATE_DIR_OUT,
> +};

Any specific reason to first define such a nice enum and then using int
in the struct?

MfG, JBG

--=20
Jan-Benedict Glaw       jbglaw@lug-owl.de    . +49-172-7608481             =
_ O _
"Eine Freie Meinung in  einem Freien Kopf    | Gegen Zensur | Gegen Krieg  =
_ _ O
 fuer einen Freien Staat voll Freier B=C3=BCrger" | im Internet! |   im Ira=
k!   O O O
ret =3D do_actions((curr | FREE_SPEECH) & ~(NEW_COPYRIGHT_LAW | DRM | TCPA)=
);

--urKaCNvFwQ8jDQOg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFB0873Hb1edYOZ4bsRAtCuAJ9evP8DkQ142XphAFaMDulpbbu15gCgieXS
cBCw52xCYS6wmYrHlrMGijM=
=44jp
-----END PGP SIGNATURE-----

--urKaCNvFwQ8jDQOg--
