From: Felipe Balbi <balbi@ti.com>
Subject: Re: [patch-net-next v2 3/3] net: ethernet: cpsw: don't requests IRQs
 we don't use
Date: Thu, 15 Jan 2015 09:20:53 -0600
Message-ID: <20150115152053.GA16409@saruman>
References: <1421254729-10602-1-git-send-email-balbi@ti.com>
 <1421254729-10602-3-git-send-email-balbi@ti.com>
 <54B770FC.6060003@ti.com>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="IS0zKkzwUGydFO0o"
Cc: Felipe Balbi <balbi@ti.com>, <davem@davemloft.net>,
	Tony Lindgren <tony@atomide.com>,
	Linux OMAP Mailing List <linux-omap@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54B770FC.6060003@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--IS0zKkzwUGydFO0o
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jan 15, 2015 at 01:19:16PM +0530, Mugunthan V N wrote:
> On Wednesday 14 January 2015 10:28 PM, Felipe Balbi wrote:
> > CPSW never uses RX_THRESHOLD or MISC interrupts. In
> > fact, they are always kept masked in their appropriate
> > IRQ Enable register.
> >=20
> > Instead of allocating an IRQ that never fires, it's best
> > to remove that code altogether and let future patches
> > implement it if anybody needs those.
> >=20
> > Signed-off-by: Felipe Balbi <balbi@ti.com>
>=20
> Instead of introducing dummy ISR in previous patch and then removing in
> this patch, both can be squashed into a single patch.

sure they can. I decided to split to ease review and to make sure only
one thing happens in a single patch.

--=20
balbi

--IS0zKkzwUGydFO0o
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUt9rVAAoJEIaOsuA1yqREQbsP/1BoEoxrA57EyUnHpc4/HUa+
u2ZzihTbmvA9mnZ3iL3+8TRrFyxcqzK0zyPQCvvTpob2C2ysrQbkFsb0U5+FZ+kO
vP3xq+sUeTGo9Pdsdq/ZPI0s3aD2D3RMaAG0DqArLd2x13a29Ap9/xbkwQKNiXIH
9oxuuhhLgaQmqm62WZtAegNByDBQeoDECjBrBKIx/DG43QQJ3sHlbuUFttbarl03
+lCc9FMg/scDET6ymPuJbTgiK5y95MqnZNF5ZHBCKnB0NBHcgMpHYzw7d4dqD3ab
+b+lBrRq4MyvjNFsFf2CO/kbNawWvNO6QT1osashNcomgtd39KEBQSv1WmryqeAV
XPmw/ViOWQZQWPBelcuuga76NvxC961tWpywblXb2npHOigmnXqC5WNanQYLhN+I
86JUjZN/fP65RxZSy6v4Nd/p941kMeB0bSlLJtyzmas8tPCkyRh8hQS4R3nxzfWA
5fPVOGlIuwpy9+7XW+W4E9nmx4s7cP6Cnzid6kjK+7/0J7XigzM8hFeKzzQiGXDK
N6aUwVRtuPduZ5Z58penY89ATgTnh8R2PbDW3C8VpAqtCgxBWVFjHvoYMpZzSnyu
u9SVQ7pjRviE5ebjvnQZ2qnJo5HGrNOMwB9GLSVzu9yGSNf1IR6KrzMvl1Yj1c+j
SlmsnP/9mczExAtDaBrq
=ugt3
-----END PGP SIGNATURE-----

--IS0zKkzwUGydFO0o--
