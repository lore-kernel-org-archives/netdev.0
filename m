From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] fix format mismatch in
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c
Date: Mon, 19 May 2014 17:08:27 -0700
Message-ID: <1400544507.2389.6.camel@jtkirshe-mobl>
References: <1400501090-315-1-git-send-email-toralf.foerster@gmx.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8882587309887246479=="
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com
To: Toralf =?ISO-8859-1?Q?F=F6rster?= <toralf.foerster@gmx.de>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1400501090-315-1-git-send-email-toralf.foerster@gmx.de>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============8882587309887246479==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-vGJZr56W6ZzbfXpw/+W3"


--=-vGJZr56W6ZzbfXpw/+W3
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-05-19 at 14:04 +0200, Toralf F=C3=B6rster wrote:
> spotted by cppcheck
>=20
> Signed-off-by: Toralf F=C3=B6rster <toralf.foerster@gmx.de>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)

I will add your patch to my queue and will hold off on making my
suggested change below until Shannon and Jesse have had time to review
your patch.

>=20
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net=
/ethernet/intel/i40e/i40e_debugfs.c
> index 3c37386..1bc35a2 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
> @@ -1239,7 +1239,7 @@ static ssize_t i40e_dbg_command_write(struct file *=
filp,
>  	} else if (strncmp(cmd_buf, "add pvid", 8) =3D=3D 0) {
>  		i40e_status ret;
>  		u16 vid;
> -		int v;
> +		unsigned int v;

Maybe u16 instead...

> =20
>  		cnt =3D sscanf(&cmd_buf[8], "%i %u", &vsi_seid, &v);
>  		if (cnt !=3D 2) {
> @@ -1255,7 +1255,7 @@ static ssize_t i40e_dbg_command_write(struct file *=
filp,
>  			goto command_write_done;
>  		}
> =20
> -		vid =3D (unsigned)v;
> +		vid =3D v;
>  		ret =3D i40e_vsi_add_pvid(vsi, vid);
>  		if (!ret)
>  			dev_info(&pf->pdev->dev,



--=-vGJZr56W6ZzbfXpw/+W3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABCgAGBQJTepz7AAoJEOVv75VaS+3ODN8P/17gQ2+Jjdz1g42PmP/iOV5H
kTBgUYzwLIKnfP3fEz0zNb9fn2A0UuFcyMjF0Rp/c1xcZs/3YjHNzyuq0eR0FJv7
YZ5akJSgeLs3fVq9gw0WD5NX500h+outXXWJGN6AVS45GzSimZygowTsiTxODlkr
3vY0rQMj+zMXsqFjUYoVgBCWTNdCz2N2+QUd4+DI3OypSl0Dq8esaAZmmftqKOtG
vjpHzX+RrLVk/mKnPwjU2QxLNX0mpZhbQWOPZb5MreTxHyDfCaLC0EgE1/3IJ9ld
ygMKSndkpnMdPvsWV+KIy7Z37oEPoHMtBIY59kAFJnV7UUtodjjcTUSCH7FXMOBr
reOro5q4P71jTNFZIihQ0udExR8GdBJSRWIGgF4jOAQp90QzEVIYpK593aDyqurM
zWFEAABhja2expbtOoChdvBpX8+BacxuDzex+MGOMSZUednchhePldsfR7DcucJC
U9OUzRzvGp3ooYl3a8QOopgPEb0a0hgYvh/zlmVljWaIoZVl0kQ5LKx2CsI8tK42
YMC7mDdrL8vG/MBjkKNpL1s/ZvZtaXFmRkbFNatkYOT+RcGHOCaPenISOqIzpztX
/TQiKzl1oSpzrhe0+lPhWDNb3u6gWWob+/acmCtCGYpEncu97ZHJ4J5OE8OyLCq4
orxZfRdWjcTC1Nc4zQrp
=/7MO
-----END PGP SIGNATURE-----

--=-vGJZr56W6ZzbfXpw/+W3--



--===============8882587309887246479==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
"Accelerate Dev Cycles with Automated Cross-Browser Testing - For FREE
Instantly run your Selenium tests across 300+ browser/OS combos.
Get unparalleled scalability from the best Selenium testing platform available
Simple to use. Nothing to install. Get started now for free."
http://p.sf.net/sfu/SauceLabs
--===============8882587309887246479==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============8882587309887246479==--
