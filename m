From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [PATCH V4 1/2] pci: Add dev_flags bit to access VPD through
 function 0
Date: Tue, 15 Sep 2015 21:47:35 +0000
Message-ID: <4BC72D19-784E-4320-9323-825D7D00DA67@intel.com>
References: <20150713183821.19985.52157.stgit@mdrustad-wks.jf.intel.com>
 <20150713184001.19985.64867.stgit@mdrustad-wks.jf.intel.com>
 <1442341152.23936.122.camel@redhat.com>
 <F17F8A11-FB09-4131-A404-DE106F3944BB@intel.com>
 <1442343860.23936.141.camel@redhat.com>
 <5E6FC98D-C2B9-4F69-ABB9-84A39AE6D271@intel.com>
 <1442351847.23936.155.camel@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_4DDE767D-D597-4157-9BA0-0C1338E03777";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: "bhelgaas@google.com" <bhelgaas@google.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Myron Stowe <myron.stowe@redhat.com>
To: Alex Williamson <alex.williamson@redhat.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1442351847.23936.155.camel@redhat.com>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Apple-Mail=_4DDE767D-D597-4157-9BA0-0C1338E03777
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

> On Sep 15, 2015, at 2:17 PM, Alex Williamson =
<alex.williamson@redhat.com> wrote:
>=20
> Also, rather than clearing the flag, can we move the tests done by
> pci_vpd_f0_dev_check() into the
> quirk setup function?  It seems like function 0 should be sufficiently
> configured by the time we're probing non-zero functions that we can be
> more selective in setting the flag rather than unsetting it later.

I guess I was being very conservative in not assuming anything about the =
state of other devices at that point. Things seem to be increasingly =
parallel all the time and I am not deeply involved in the evolution of =
the PCI subsystem. If you want to make that assumption, I would suggest =
that pci_vpd_f0_dev_check remain a separate function called by the quirk =
setup so that it can be used by other quirk setup functions as well.

--
Mark Rustad, Networking Division, Intel Corporation


--Apple-Mail=_4DDE767D-D597-4157-9BA0-0C1338E03777
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJV+JH2AAoJEDwO/+eO4+5uTK8P/2Ly2e3rjHyyCaTmTwcYXhEo
ZSZgMqkxDeBmV6pAN6IZSwWdJwIoqh8YUTxxpwyCe4+VoXeVHip/+zTKHnBJslXT
zpA+Di0+32okCXEw/JUdUGMkwqh4BQIlQyBIPVM8bBJYmzcP0PdcxvkgAiiF0fTJ
R78IBzZYPBtP+MdEMNlIjcmeuhD1DAC7IoslHzF3MdI/EGZRrjv3cpGenQAV17nk
rn7h6PQup9I2LdiJBeN6NAnkCMrqA+yYrjfetEm8lD+kvsGIHz+tMzFHRSYqYl8m
x18RhzSTk+dwZSHicht7ydHjiur8/HQ5bOFtVGqkmoT6aB5rPd6h8cMjU21cd30S
vTQjXgaUaIEHBL/XuOmGgOWQtG0Qhg12nlPW9jMmjvmke3hv8IEc0kOempaAXxAe
lw8qEs42NRgqleCO2aXgPQjgUHZqH0uMaFrNMvztOeirq2OQUmXI56lhaibmVcdr
BWexFAlB2fMhYOOIM1J+TEImqCeauFtwM304w8iUggSoGs0Yb2htBy0JpbjLmp+N
vXKnFnsP4VaDIIVYJeCz5wg8GU4MN6AHqcRV7HtuDIZ/HqZd/uOlUDtoLxtNY1f+
odEwRDvBEeUgD0yp7F8YdVq5uRd+V92SHnoz/elqPAHBzOH8azY1nz5Uk6eqoEmA
JYbdyuuGeFjfPU7J8aB4
=UMSK
-----END PGP SIGNATURE-----

--Apple-Mail=_4DDE767D-D597-4157-9BA0-0C1338E03777--
