From: Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH] f_phonet: fix skb truesize underestimation
Date: Wed, 28 Mar 2012 15:43:14 +0300
Message-ID: <20120328124314.GG28319@arwen.pp.htv.fi>
References: <1332853442.3248.15.camel@edumazet-laptop>
 <20120327.225109.752822925052179338.davem@davemloft.net>
 <20120328085535.GF18156@arwen.pp.htv.fi>
 <20120328.053310.219141897175161116.davem@davemloft.net>
Reply-To: balbi-l0cyMroinI0@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="bygAmIonOAIqBxQB"
Cc: balbi-l0cyMroinI0@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120328.053310.219141897175161116.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--bygAmIonOAIqBxQB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Mar 28, 2012 at 05:33:10AM -0400, David Miller wrote:
> From: Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>
> Date: Wed, 28 Mar 2012 11:55:36 +0300
>=20
> > On Tue, Mar 27, 2012 at 10:51:09PM -0400, David Miller wrote:
> >> From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> >> Date: Tue, 27 Mar 2012 06:04:02 -0700
> >>=20
> >> > Now skb_add_rx_frag() has a truesize parameter, we can fix f_phonet =
to
> >> > properly account truesize of each fragment : a full page.
> >> >=20
> >> > Signed-off-by: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> >>=20
> >> Applied.
> >=20
> > did you apply both patches ?
>=20
> You never need to ask me these kinds of questions, you can
> either check my GIT tree or look at:
>=20
> http://patchwork.ozlabs.org/project/netdev/list/?state=3D3

I'm asking because drivers/usb/gadget/ should either go through me or
you should wait for my Acked-by. Now it's too late for that, but next
time for my Ack.

--=20
balbi

--bygAmIonOAIqBxQB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPcwdhAAoJEIaOsuA1yqREW+YP/1ID/2IoPIOgThGBnDJiLBt+
HVmpmp7EZE/0Gegb48OCDt7xnCI+MITeI+bh22nhP6BYf95TY+trV+Ncjp+Zu4E6
YKOvBHoiDlwVWR2o3nGH7QuRyLAtyUa3u/oCVevUDKRTgZT2t+elInOS2PgEXiot
RamOcAII74OnVh8/w+nFTDzKZwPMGAAgH9NC6SwQPMXo+y2AF0O2NNh+hB5eEbGs
0oGnxCD4brEnruNJ+2E5OVSMPFDbbHnGIdbyZcchsUVtkUfH1DAswDanSlvYz5o0
fWEYIbVmfTBg53VrInvuFbFV5guoJbYnMxa6Rbwh69NMBVFyjYJsOoI5gkoHQfTC
gSRAcIcz599lcs3OkGt58PogcypFQ0TLw6zmFt7+64RvGbDWXKakJ3XU2KRDQ7Zc
spyusWCTiz0gIGAdzqt3dcHYmD2c/TnF9OLtSNHERWNw1BkJVRrXJirAe9vO0Y27
vCw/CJDPr35/nJ9diPfoNQxDmmnxQZDmL1AAMxE692wrs2HePs3VnYY1C4/e5wiX
Hv0X9kdgbB/Ox+hqYFpiL1/crfWTjYlQGlRdDNQThkWL8vD/SlRb44CrXGQdR/TY
09eqrvlyfmzmBqNEECPWyu6VZFZXQ1qseoKhMFkG3IZdxibGmUcG4/Pyp7ArAJ6I
CLyLs7EwoZ538ws6wpcD
=Cgzu
-----END PGP SIGNATURE-----

--bygAmIonOAIqBxQB--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
