From: Cyril Brulebois <kibi@debian.org>
Subject: Re: [PATCH] wireless: rt2x00: add new rt2800usb device
Date: Wed, 29 Oct 2014 12:12:24 +0100
Message-ID: <20141029111224.GC29720@mraw.org>
References: <1414510961-28920-1-git-send-email-kibi@debian.org>
 <20141029110214.GB2021@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="5G06lTa6Jq83wMTw"
Cc: Helmut Schaa <helmut.schaa@googlemail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, users@rt2x00.serialmonkey.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141029110214.GB2021@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--5G06lTa6Jq83wMTw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Stanislaw Gruszka <sgruszka@redhat.com> (2014-10-29):
> On Tue, Oct 28, 2014 at 04:42:41PM +0100, Cyril Brulebois wrote:
> > 0x1b75 0xa200 AirLive WN-200USB wireless 11b/g/n dongle
> >=20
> > References: https://bugs.debian.org/766802
> > Reported-by: Martin Mokrejs <mmokrejs@fold.natur.cuni.cz>
>=20
> Was this patch tested by reporter? I would rather see Reported-and-tested=
-by tag :-)

The reporter confirmed the following trick worked:

  # echo rt2800usb >> /etc/modules
  # echo 'install rt2800usb /sbin/modprobe --ignore-install rt2800usb $CMDL=
INE_OPTS && echo 1b75 a200 > /sys/bus/usb/drivers/rt2800usb/new_id' > /etc/=
modprobe.d/ralink.conf
  # modprobe -r rt2800usb ; modprobe rt2800usb

but I'll try and get this patch tested on top of 3.16.x (which is what
we have in Debian at the moment) if that's good enough for you.

Mraw,
KiBi.

--5G06lTa6Jq83wMTw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJUUMuYAAoJEP+RSvDCs1UgqXoP/ir73I8VkEWvHsLs56Wc2Jo5
Wf4Zpr19uj1KGuktexF8UpaIdzi84Ot3DWW3L0Jxb8GtBE3yr1MNDKGCQ+yncQcw
RGqkbYb3DuAPfPb3ecg21er5dBZNZ+anu2uKcyd5nxeNh4U5N+Brr4qLapPHoNp+
FtDE68+6b1W9HmEnSMz2uZdXLUTKOYPR4je34eIt8x1pULlRpRUEUtM090q9D94s
lx2hmDxrMxTigkpJUJ2NCSen4uklS/pPpF1yd5Htst5l7TaXXxHTf+gh3Y5B+a77
VC3P/+rWbJamYtUD2jvYDUS5VlL0PaMAFYEOdoU8wFP528SJi9woVIB2WbFrULQY
mVvdsMDpn2lk+MkFy3kbHqLNTsJZvmTrvSvbOnYTmFGaVoHt/OTQDrRHHWXHyIve
RtHGdrK+qjVexHfHT4xrjnYC1Mw5/2fJOO14oCq4E/v8I/AADVCedg41pAtusKrS
hd1EQ7cLH/ewxsWXY97aRolqQNqIb842UVVANir648dIkT72CLDuialK3OLVvUNI
In+iTlEFhkJrbctPJ7Mk6fOOcuzPU9+kv3pdJgwhh7VhPzNYANsZZG7fquuyg1Pk
cTGTHaIzQP/pZhp9WlVk+ghpoL4PJmH2kWCbomZAK2vQOCQu8O5aQKQ/mloYVH0r
MIP0hb1J8kEsVOtAwR/M
=VB1b
-----END PGP SIGNATURE-----

--5G06lTa6Jq83wMTw--
