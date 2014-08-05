From: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH] net: sun4i-emac: fix memory leak on bad packet
Date: Tue, 5 Aug 2014 23:07:04 +0200
Message-ID: <20140805210704.GG2019@lukather>
References: <1407253479-30076-1-git-send-email-marc.zyngier@arm.com>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="YH9Qf6Fh2G5kB/85"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	Stefan Roese <sr-ynQEQJNshbs@public.gmane.org>
To: Marc Zyngier <marc.zyngier-5wv7dgnIgG8@public.gmane.org>
Return-path: <linux-sunxi+bncBD2ZNBF5VYJRBKUQQWPQKGQERQFRCIY-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1407253479-30076-1-git-send-email-marc.zyngier-5wv7dgnIgG8@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <http://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org


--YH9Qf6Fh2G5kB/85
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Aug 05, 2014 at 04:44:39PM +0100, Marc Zyngier wrote:
> Upon reception of a new frame, the emac driver checks for a number
> of error conditions, and flag the packet as "bad" if any of these
> are present. It then allocates a skb unconditionally, but only uses
> it if the packet is "good". On the error path, the skb is just forgotten,
> and the system leaks memory.
>=20
> The piece of junk I have on my desk seems to encounter such error
> frequently enough so that the box goes OOM after a couple of days,
> which makes me grumpy.
>=20
> Fix this by moving the allocation on the "good_packet" path (and
> convert it to netdev_alloc_skb while we're at it).
>=20
> Tested on a random Allwinner A20 board.
>=20
> Cc: Stefan Roese <sr-ynQEQJNshbs@public.gmane.org>
> Cc: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
> Cc: <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org> # 3.11+
> Signed-off-by: Marc Zyngier <marc.zyngier-5wv7dgnIgG8@public.gmane.org>

Acked-by: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>

Thanks!
Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com

--YH9Qf6Fh2G5kB/85
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJT4Ud4AAoJEBx+YmzsjxAgWWYP/ji640bhoX+Sv4GNn+8d38DY
x+aTw2/62VYP/6vwnXumM/0PI8Ve1sFzqjnLnC91sx4MsGsvb84nmkhvYKcZET9y
5xOtN8OQxLR9KXTvtmaOuSA7QWIv2N5TPZR6MtTG2myEx4M1puNFm/Nltw+CoR2Y
yMOUvy/Sn9rDAiG8RpLnZ+17lgFqC3yBs80mtIRCX9Bw4LKWqBfzaoybjREyFhdV
kHOriX73BrT3aez2tiTKn62xWE2DS9P9P0RH9fBSP3RFhTqTCfN1BSJOFuIjF27d
dSqlJaFgC9QhFPDDV0SNC+fsWqJ0rwU+e4vx6GUbww5tetn/FNXeFNSL8N4ekZv0
rFBnrrrwTcamIwl8Tb2aBjzIVg8fn16sV7xqOwKNHTi0RBCB1rnVnEeKDtb1s60i
KfDGeS0t2ibdqP9JHljy64smHt16zSrITDc22KRSRMeITYSmn6kO45BnOX8k4YE4
xxrGNBotPq2q0witPEIZ2sJNTh6zmuci5HSkdmuGrnqji2YlKvdtUJrbLX5Bni/P
mWND9h1CjMrzkumpUuNkC9EzQdCWtiuKuJKewf+Qdy5C9U4RBILD0EHPMmGgpAFu
kfEEuY7YZI1b2DkJceldKEeXmApblCS0m0/UFqYxvqrbh5xYuPi3UEu956xcUnvp
2eTMV4v96fimTltE3IuF
=Mbjq
-----END PGP SIGNATURE-----

--YH9Qf6Fh2G5kB/85--
