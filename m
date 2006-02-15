From: Michael Buesch <mbuesch-KuiJ5kEpwI6ELgA04lAiVw@public.gmane.org>
Subject: Re: [PATCH wireless-2.6] bcm43xx-d80211: fix oops when removing the module
Date: Wed, 15 Feb 2006 22:34:35 +0100
Message-ID: <200602152234.35463.mbuesch@freenet.de>
References: <20060215202147.69b82ee2@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1589872.N9lxd7XnCa";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
   NetDev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-admin-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Jiri Benc <jbenc-AlSwsSmVLrQ@public.gmane.org>
In-Reply-To: <20060215202147.69b82ee2-IhiK2ZEFs2oCVLCxKZUutA@public.gmane.org>
Sender: bcm43xx-dev-admin-tdrK/OAtAx2ELgA04lAiVw@public.gmane.org
Errors-To: bcm43xx-dev-admin-tdrK/OAtAx2ELgA04lAiVw@public.gmane.org
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Subscribe: <http://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
List-Unsubscribe: <http://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.berlios.de/pipermail/bcm43xx-dev/>
List-Id: netdev.vger.kernel.org

--nextPart1589872.N9lxd7XnCa
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Wednesday 15 February 2006 20:21, you wrote:
> This patch fixes an oops when bcm43xx-d80211 module is unloaded.

This is already fixed in my tree.

> Signed-off-by: Jiri Benc <jbenc-AlSwsSmVLrQ@public.gmane.org>
>=20
> --- dscape.testing.orig/drivers/net/wireless/bcm43xx-d80211/bcm43xx_main.=
c	2006-02-15 20:06:07.000000000 +0100
> +++ dscape.testing/drivers/net/wireless/bcm43xx-d80211/bcm43xx_main.c	200=
6-02-15 20:07:17.000000000 +0100
> @@ -4785,7 +4785,8 @@ static void __devexit bcm43xx_remove_one
>  	ieee80211_unregister_hw(net_dev);
>  	bcm43xx_detach_board(bcm);
>  	destroy_workqueue(bcm->workqueue);
> -	kfree_skb(bcm->cached_beacon);
> +	if (bcm->cached_beacon)
> +		kfree_skb(bcm->cached_beacon);
>  	assert(bcm->ucode =3D=3D NULL);
>  	ieee80211_free_hw(net_dev);
>  	kfree(ieee);
>=20
>=20

=2D-=20
Greetings Michael.

--nextPart1589872.N9lxd7XnCa
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQBD855rlb09HEdWDKgRAt9IAJ9PMNRrl5snSoFRc5lvoAoUsYzG/QCeKnfY
PgV4J9/11u4QOxw4qO7Tq3A=
=a5yh
-----END PGP SIGNATURE-----

--nextPart1589872.N9lxd7XnCa--
