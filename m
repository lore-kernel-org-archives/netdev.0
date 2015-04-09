From: Wolfram Sang <wsa-z923LK4zBo2bacvFa/9K2g@public.gmane.org>
Subject: Re: [PATCH 12/14] i2c-parport: return proper error values from attach
Date: Thu, 9 Apr 2015 12:25:28 +0200
Message-ID: <20150409102528.GC1166@katana>
References: <1428492040-5581-1-git-send-email-sudipm.mukherjee@gmail.com>
 <1428492040-5581-13-git-send-email-sudipm.mukherjee@gmail.com>
 <20150409071307.GA1166@katana>
 <20150409113342.5621af83@endymion.delvare>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="bKyqfOwhbdpXa4YI"
Cc: Sudip Mukherjee <sudipm.mukherjee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Rodolfo Giometti <giometti-AVVDYK/kqiJWk0Htik3J/w@public.gmane.org>,
	"James E.J. Bottomley" <JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Mark Brown <broonie-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Willy Tarreau <willy-859RlTSWH48dnm+yROfE0A@public.gmane.org>,
	Jaroslav Kysela <perex-/Fr2/VpizcU@public.gmane.org>, Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-spi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org,
	alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org
To: Jean Delvare <jdelvare-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-spi-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20150409113342.5621af83-R0o5gVi9kd7kN2dkZ6Wm7A@public.gmane.org>
Sender: linux-spi-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--bKyqfOwhbdpXa4YI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


> It doesn't really matter that the error codes are different, it matters
> that they are meaningful. As much as possible you should pass error
> codes from the lower layers. parport_claim_or_block() and
> i2c_bit_add_bus() return proper error codes so you should record and
> transmit them.

Oh, surely yes. I assumed they don't and this series is a first step to
fix this. Should have looked myself. Thanks for jumping in here.


--bKyqfOwhbdpXa4YI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVJlOYAAoJEBQN5MwUoCm2PpgP/1MTplCt+Gjk06kYCV2YpxIv
5zTjJsS43a95yR+TC332DLCI7WbSWwiLY3+5aDWqE7Tzqb8vM6tob0HL4OVEVmyN
UZymI9gOBWbjMPGZqE5e37INqojwpiUvByl02st9nTGoou6G+JG4M4Ores5zSwgs
n3Z/zSK9bbW/i1MtCtvZ0hdYab0UHrdQ2nrizMBG/PI/w+mcE5iHTOcSB11LvvBL
hytC2M7TBQ+rbLCMJf5nh2g7M2K5gZmZw4mXrh9C49fXh4LpINltohM9s6MCqUxi
JtoPtf3FK3asim28qcTdhqESJ5qogQBWp5eE6RKY9ELROeMoslComGT0kt0FoB58
SIVChAGFcTQly6TNPITdft0cSGtppQh6tjgrVgDpv3behoBlT2rlwPWfY3Kx37/M
JLvg6BguO4t10nUSWedKeW0y88UFqdb3kShV9bQMqHrQ+cyir7L/L3gKZUrx81ku
YXWjkAojjk4kS7+IB8zzKAhl9bQOdntsK1oE79E6O+0A2UDfOdGXXJJK8UR+Dq9D
/lcXHipIB2+oqcUAsV6GSxxnRzUjS4fCsNXjpuUbziAYDtAk+aVoGc9r12kqd3iH
ik1LFz7ONBXmf55Dsf6RwhOdvBmMDmpHwQR/0oN6ah6ySm5JndooGxedwvaSiIk5
DrntpQ2FDo/lOgro8X2U
=/a/0
-----END PGP SIGNATURE-----

--bKyqfOwhbdpXa4YI--
--
To unsubscribe from this list: send the line "unsubscribe linux-spi" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
