From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v7 8/8] net: e1000e: Adds hardware supported cross
 timestamp on e1000e nic
Date: Thu, 18 Feb 2016 16:43:23 -0800
Message-ID: <1455842603.3128.61.camel@intel.com>
References: <1455308729-6280-1-git-send-email-christopher.s.hall@intel.com>
	 <1455308729-6280-9-git-send-email-christopher.s.hall@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-bHIfEZfFARIxevVYQY+t"
Cc: x86@kernel.org, linux-kernel@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	kevin.b.stanton@intel.com, kevin.j.clarke@intel.com
To: "Christopher S. Hall" <christopher.s.hall@intel.com>,
	tglx@linutronix.de, richardcochran@gmail.com, mingo@redhat.com,
	john.stultz@linaro.org, hpa@zytor.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455308729-6280-9-git-send-email-christopher.s.hall@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-bHIfEZfFARIxevVYQY+t
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-02-12 at 12:25 -0800, Christopher S. Hall wrote:
> Modern Intel systems supports cross timestamping of the network
> device
> clock and Always Running Timer (ART) in hardware.=C2=A0 This allows the
> device time and system time to be precisely correlated. The timestamp
> pair is returned through e1000e_phc_get_syncdevicetime() used by
> get_system_device_crosststamp().=C2=A0 The hardware cross-timestamp resul=
t
> is made available to applications through the PTP_SYS_OFFSET_PRECISE
> ioctl which calls e1000e_phc_getcrosststamp().
>=20
> Signed-off-by: Christopher S. Hall <christopher.s.hall@intel.com>
> [jstultz: Reworked to use new interface, commit message tweaks]
> Signed-off-by: John Stultz <john.stultz@linaro.org>
> ---
> =C2=A0drivers/net/ethernet/intel/Kconfig=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 |=C2=A0 9 +++
> =C2=A0drivers/net/ethernet/intel/e1000e/defines.h |=C2=A0 5 ++
> =C2=A0drivers/net/ethernet/intel/e1000e/ptp.c=C2=A0=C2=A0=C2=A0=C2=A0 | 8=
5
> +++++++++++++++++++++++++++++
> =C2=A0drivers/net/ethernet/intel/e1000e/regs.h=C2=A0=C2=A0=C2=A0 |=C2=A0 =
4 ++
> =C2=A04 files changed, 103 insertions(+)

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

I am fine with Christopher's changes, so when the issues with the other
patches in the series gets ironed out, your good to apply this patch as
well John.
--=-bHIfEZfFARIxevVYQY+t
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJWxmUrAAoJEOVv75VaS+3OAgcP/0eI6plS41gJETN17cEEyOPg
5aXpG/w8huWFykXQYaQIYKveJ9KNv51ArdqUU10cBwMJG7OCV85/OkOpwR5U7kQL
TiV9TIjB0Y7JI1MfyQdc8TYlfGuYUdwd5UkQzbJLHjcanrEGJMgPfC4Ub36oL5n2
/3hgb4R5qmh2hFBpvD0TCYasZ0l1axuXxFgpD9IYt2kXty4nEGQObjsmncn5rd4c
0vihY8PIM2rgIuDGyzlVk0YVz/kIxjGuRH7BH0OQgm4vTPY1cOmaiXvrQB2IHz1W
Za1CpSY9ub/KkhOW2w55YLWk8hM2c3t434bKyVIV1p81bzKUiXE0Xu8kRYouxhwr
nXD7vj9dOXoBoI/FgeyBX7d33dRfdlSBVubqu4wP0t4gWirN8uIk/2lSKyPfuLxB
WWGeb3GXIc+ix85QkdSAVLaIlqWZ9wXZW8iojLFUS2hZyPZ7O/rFbZQGV4k4PTao
98zjKvxhZjaAVNSSxKP99MCokLNedOptj03WnZeNz653FOEngy7Gxgf3hDiYoX9J
uNTh1mT4t+kNuhfUJXhXe1mKm2b4R4/Y38+ILWPnGUlqR1SVklHndFlK5Hpv7ENH
DN+a2czZN44ppfj8E2CYOaZVHgEussBhGCObtX8MOL1gxYHeo2SJt/zcjFOsgRcl
C3qFHja1LCiHEeJd6gGE
=9vbl
-----END PGP SIGNATURE-----

--=-bHIfEZfFARIxevVYQY+t--
