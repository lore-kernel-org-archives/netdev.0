From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [PATCH v4 10/10] ARM: sunxi: Enable sun8i-emac driver on
 multi_v7_defconfig
Date: Tue, 11 Oct 2016 11:40:42 +0200
Message-ID: <20161011094042.GS3462@lukather>
References: <1475828757-926-1-git-send-email-clabbe.montjoie@gmail.com>
 <1475828757-926-11-git-send-email-clabbe.montjoie@gmail.com>
 <20161010123046.GH3462@lukather> <20161010123511.GA16103@Red>
 <20161010150943.fa7ca85fe52f4c6f9508b5eb@free.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4429620913833130805=="
Cc: mark.rutland@arm.com, andrew@lunn.ch, f.fainelli@gmail.com,
 devicetree@vger.kernel.org, netdev@vger.kernel.org, linux@armlinux.org.uk,
 linux-kernel@vger.kernel.org, wens@csie.org, robh+dt@kernel.org,
 LABBE Corentin <clabbe.montjoie@gmail.com>, davem@davemloft.net,
 linux-arm-kernel@lists.infradead.org
To: Jean-Francois Moine <moinejf@free.fr>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20161010150943.fa7ca85fe52f4c6f9508b5eb@free.fr>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org


--===============4429620913833130805==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="3yk1sSvxP8cRAjBs"
Content-Disposition: inline


--3yk1sSvxP8cRAjBs
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Oct 10, 2016 at 03:09:43PM +0200, Jean-Francois Moine wrote:
> On Mon, 10 Oct 2016 14:35:11 +0200
> LABBE Corentin <clabbe.montjoie@gmail.com> wrote:
>=20
> > On Mon, Oct 10, 2016 at 02:30:46PM +0200, Maxime Ripard wrote:
> > > On Fri, Oct 07, 2016 at 10:25:57AM +0200, Corentin Labbe wrote:
> > > > Enable the sun8i-emac driver in the multi_v7 default configuration
> > > >=20
> > > > Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> > > > ---
> > > >  arch/arm/configs/multi_v7_defconfig | 1 +
> > > >  1 file changed, 1 insertion(+)
> > > >=20
> > > > diff --git a/arch/arm/configs/multi_v7_defconfig b/arch/arm/configs=
/multi_v7_defconfig
> > > > index 5845910..f44d633 100644
> > > > --- a/arch/arm/configs/multi_v7_defconfig
> > > > +++ b/arch/arm/configs/multi_v7_defconfig
> > > > @@ -229,6 +229,7 @@ CONFIG_NETDEVICES=3Dy
> > > >  CONFIG_VIRTIO_NET=3Dy
> > > >  CONFIG_HIX5HD2_GMAC=3Dy
> > > >  CONFIG_SUN4I_EMAC=3Dy
> > > > +CONFIG_SUN8I_EMAC=3Dy
> > >=20
> > > Any reason to build it statically?
> >=20
> > No, just copied the same than CONFIG_SUN4I_EMAC that probably do
> > not need it also.
>=20
> All arm configs are done the same way, and, some day, the generic ARM
> V7 kernel will not be loadable in 1Gb RAM...

Yeah, if possible, I'd really like to avoid introducing statically
built drivers to multi_v7.

Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--3yk1sSvxP8cRAjBs
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX/LOZAAoJEBx+YmzsjxAgxmgQALeAuyWRqmYRLJywDjWIrj4f
zbXpvwax4JQhEZV0tMGkWibSwwy92F2x3f/KMBYe6zlkFTKmw5L/VeUl8CpwSjXR
zVCozV3ZAC/Oe15pr16jgPtVrJuPdI8tDAavNskPfN2AmtWdIqlVCcg5RINEZ+xY
rHdOz8HN97hJwdxrhT8DhPVY4hTtE0frZTEfLz5tx+Vs/bODUYcPvrhqQNyyyVME
rWGhBxw+2WB16HYbK61kozbPHP8+Lq+jv0J42v0mHLW2WRSMUtPeoyjAdNM0AlPx
+g81r9SMEGGDUxN73uUzZeXz30ixbWXV06HLSEBok9+cX1l7pFq91yZPb7rtNx5A
eDTRFrZ49Uwe8jHZzA9OzwAOZf0hF3RRI/Wh+iWEwZUOM/t0lr4shisBuJkt+a1A
GRT7HVtoNVghT7e+xx6BUeJq69aVCvcu5LWpi07oIzE8F95qX2EOi8HR0kl8pPua
dDsMSeZ2jJuxMnBoEw91RLRnuGyM8qqDW0ISCI0cV9i0WevJC0FxHeutETYzFWuR
4Ynu2OeN4S3rywYZl1Ok7GuKPnmxH1/jzsli79bzPiztu+9PwddSPLepVrWhtgG6
zKWUfJuHXXt6ukkVrCRDK0hQMF132COwIE/MO8UxYU9JBV0N36Rcy6Bm5bQaXAf1
ESZvDlUa59ubBkkKC8Tn
=nJX1
-----END PGP SIGNATURE-----

--3yk1sSvxP8cRAjBs--


--===============4429620913833130805==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
linux-arm-kernel mailing list
linux-arm-kernel@lists.infradead.org
http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

--===============4429620913833130805==--
