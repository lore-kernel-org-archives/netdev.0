From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] ethtool: return 1 as exit code on a settings(-s)
 failure.
Date: Thu, 16 Apr 2015 22:11:59 +0100
Message-ID: <1429218719.3211.119.camel@decadent.org.uk>
References: <1429217709-21625-1-git-send-email-sridhar.samudrala@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-AunGeNmCQJ6AMXWrJlR7"
Cc: netdev@vger.kernel.org
To: Sridhar Samudrala <sridhar.samudrala@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53186 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750856AbbDPVMM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 17:12:12 -0400
In-Reply-To: <1429217709-21625-1-git-send-email-sridhar.samudrala@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-AunGeNmCQJ6AMXWrJlR7
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2015-04-16 at 13:55 -0700, Sridhar Samudrala wrote:
> Currently 0 is returned on both success or failure.

Previously discussed here:
<http://thread.gmane.org/gmane.linux.network/349717>.

Ben.

> Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
> ---
>  ethtool.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/ethtool.c b/ethtool.c
> index 01b13a6..163dff2 100644
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -2352,7 +2352,7 @@ static int do_sset(struct cmd_context *ctx)
>  	int argc =3D ctx->argc;
>  	char **argp =3D ctx->argp;
>  	int i;
> -	int err;
> +	int err =3D 0;
> =20
>  	for (i =3D 0; i < ARRAY_SIZE(flags_msglvl); i++)
>  		flag_to_cmdline_info(flags_msglvl[i].name,
> @@ -2665,7 +2665,7 @@ static int do_sset(struct cmd_context *ctx)
>  		}
>  	}
> =20
> -	return 0;
> +	return err ? 1 : 0;
>  }
> =20
>  static int do_gregs(struct cmd_context *ctx)

--=20
Ben Hutchings
Humour is the best antidote to reality.

--=-AunGeNmCQJ6AMXWrJlR7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVTAlpOe/yOyVhhEJAQooChAAsouHsNWybf8rXKzk7jxacAdxGu9Giddh
J3WPt9xINXnKkfDH41iyIoqPzT2RQ/GjfynuQBMIE1Q2FlqR8LJ1JUQTawfFbuks
sokmTWHUG7E6RIroA4pn0zlPipfY7TVgrxcpQkAI7caFwyPkkm8IJRZXJEOBHmgh
NccGPiRcAyJftlukGdbiSCLGRnB1gtaX5uY8yuhJ8jjZohAYgVZgoTCCbO/dbnUW
plzeTaui1nIYK8KfLuO+xbokJSRUv1BmjsFqR8irevmaQQVQLw1myNlw2Xsr8+aY
Xe8vfg2p0pwnOkZXKNP+N7Z+Nz5NQ+IMknK4enFPvpGakDXL+lzXMktn6MU4jWfV
/8nPFe5hrRC8QFOu5lkQQtS78+eU0u6C0uzvJiXIoRNm0zx0WxSdyimlpOw9lz/Z
odfbGmE1MzuxJ9iJnMGWGly1YTN9BbRD4KZNqOllIYGZyFXvG/SbPaREQlfR2jM/
GuWApmW42HSObDW2wmPRWU5+Nw6WVXMIWMzP/IAlrdLDZgXb76S49YvKQvFgZQCC
4nGAnrBX3ntJBp4a5SyWLXNa836pJHW1ZypitEMKLtAsOTF0LUGZ7A12PizGCEQh
mw8479e5t7adBBcVtC2TkJk1qXay0aeJrdGKicyWSa8pCqcBGvRazlRMALP9caUP
C/pJug1IOI8=
=vpcu
-----END PGP SIGNATURE-----

--=-AunGeNmCQJ6AMXWrJlR7--
