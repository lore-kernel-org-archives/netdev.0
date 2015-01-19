From: Felipe Balbi <balbi@ti.com>
Subject: Re: [patch-net-next v3 2/2] net: ethernet: cpsw: don't requests IRQs
 we don't use
Date: Mon, 19 Jan 2015 08:40:17 -0600
Message-ID: <20150119144017.GB20386@saruman>
References: <1421424672-19323-1-git-send-email-balbi@ti.com>
 <1421424672-19323-2-git-send-email-balbi@ti.com>
 <20150118.010750.480741880077015933.davem@davemloft.net>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="6sX45UoQRIJXqkqR"
Cc: <balbi@ti.com>, <tony@atomide.com>, <linux-omap@vger.kernel.org>,
	<mugunthanvnm@ti.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-omap-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150118.010750.480741880077015933.davem@davemloft.net>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--6sX45UoQRIJXqkqR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Jan 18, 2015 at 01:07:50AM -0500, David Miller wrote:
> From: Felipe Balbi <balbi@ti.com>
> Date: Fri, 16 Jan 2015 10:11:12 -0600
>=20
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
> Applied.

looks like randconfig caught a build break. Do you want an incremental
patch or this patch again with the fix in it ?

--=20
balbi

--6sX45UoQRIJXqkqR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUvRdQAAoJEIaOsuA1yqRExS8QAKrdEGMntztP//KqtJXE/EpE
clE1VYCoJr4koFJvcKMPzmawfEQYzg1kDbMbdRm4zP2xLIcTNejqvRK4urvXuwsW
fdztzsAFPD4Kn0rcOHuGIR7tid6joKmyAtbuY65zkRg8Jq96hfflMhdBJzWmsuWo
yxeQ6XWNkm0O9aH95Q8wFDjFGuLNVJbwy+VBGHV8IyDB9FyHmfmyQGigSZGnvymT
Y/2HEI2GSQwtvLpBP0HFS2/BDzFPUFeEgFU3TdLfzayugYh8LXV+lg804uYTfZJD
6xlKPZwcXeU0Wnk5wEBCt6NmmoOs/7G46MekQv8fhXY4Gn0M2fFyi174jA7Bb+kd
ojNqUa/DWvDnF4HZMGiQ8Mwn1PT0H566sJsNu70KikatOgXl2j/w+mKN0IMZMW4m
5CYajdpdNZC+S/hAeWseEaafJfaccjcE3SBZ2lIC/tN4A8xmGCQckTtLHbWGjWwz
1VHfYNZ99a0cREkOfDFPY8dcHqrg4TG63hKhp5e4b5Z2HBheYwSAI+ql9NeKT/Or
Xp1D0hoSWdSRmmt3etzJxFtTxma4U21UICBJyMHR+4bW1RXExiQPAHGrfZjG5s/R
TcK3jU4mAQUUpDeQ2dZqVT6TWxHtlZGb92yPH8HPYAgVL3RjUhqQTw1EtyP75hDj
aTEo5gjSG1LogVOrKKWt
=4tjn
-----END PGP SIGNATURE-----

--6sX45UoQRIJXqkqR--
