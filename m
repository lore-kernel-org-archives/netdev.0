From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v3 0/6] Introduce pci_(request|release)_(mem|io)_regions
Date: Wed, 08 Jun 2016 16:04:46 -0700
Message-ID: <1465427086.2736.93.camel@intel.com>
References: <cover.1465200424.git.jthumshirn@suse.de>
	 <20160608072854.ivcfvtlgxab2xkmp@c203.arch.suse.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-zC7eTGCNtDeX7ZGFAIvU"
Cc: linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org,
	Christoph Hellwig <hch@infradead.org>,
	Keith Busch <keith.busch@intel.com>, Jens Axboe <axboe@fb.com>,
	linux-nvme@lists.infradead.org,
	James Smart <james.smart@avagotech.com>,
	Dick Kennedy <dick.kennedy@avagotech.com>,
	"James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
	"Martin K. Petersen" <martin.petersen@oracle.com>,
	linux-scsi@vger.kernel.org,
	Frank Haverkamp <haver@linux.vnet.ibm.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org
To: Johannes Thumshirn <jthumshirn@suse.de>,
	Bjorn Helgaas <bhelgaas@google.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20160608072854.ivcfvtlgxab2xkmp@c203.arch.suse.de>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-zC7eTGCNtDeX7ZGFAIvU
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-06-08 at 09:28 +0200, Johannes Thumshirn wrote:
> On Tue, Jun 07, 2016 at 09:44:00AM +0200, Johannes Thumshirn wrote:
> > The first patch in this series introduces the following 4 helper
> functions to
> > the PCI core:
> >=C2=A0
> > * pci_request_mem_regions()
> > * pci_request_io_regions()
> > * pci_release_mem_regions()
> > * pci_release_io_regions()
> >=C2=A0
> > which encapsulate the request and release of a PCI device's memory or
> I/O
> > bars.
> >=C2=A0
> > The subsequent patches convert the drivers, which use the
> > pci_request_selected_regions(pdev,=C2=A0
> >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0pci_select_bars(pdev, IORESOUR=
CE_MEM), name);=C2=A0
> > and similar pattern to use the new interface.
> >=C2=A0
> > This was suggested by Christoph Hellwig in
> > http://lists.infradead.org/pipermail/linux-nvme/2016-May/004570.html=C2=
=A0an
> d
> > tested on kernel v4.6 with NVMe.
> >=C2=A0
>=20
> Btw, as I've seen already Jeff applying the Intel Ethernet patch to his
> tree, I think this should go via the PCI tree as the build dependency is
> the PCI patch.

Bjorn should pick up the entire series, I just applied the Intel patch (and
dependent patches) so we could touch test it.
--=-zC7eTGCNtDeX7ZGFAIvU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXWKSOAAoJEOVv75VaS+3OAnQP+wVbbdkRZ4OU3PFunU41inCW
RWb2kuv+vlvJp/8mXaDTKLFZ0tV7q9J+9DEGrJox1EzUz8W+IY2tY1Z8qYKsozHF
Z42pe7dtY9wHCB4y1AaEynVEjzf5Y2Fo1Un9K7G2xSjnjMn7aPXfLTPCkb3cluIg
xFWcXncbpeyrU73AS3I9FeGNbMa9xG9iklFBrCdFpeQU+KQGm/BigZ12ymb+0VBk
Ny592PXXaa/y+tFOdreTu7gX2TF2Y0hoXYeOw847PIdJL14oWm1jSugi7nUSapoM
KCXz9+QcLSNmjFhzrfbRjh/j9CSTp3BU00kl2GfO84nOqXfVAaIpgC7sNf3vkwL+
oMzV1eK7KTwT5Ot3xDJ6XTKYOWgjKCOqgBW8wHhq9T5/OFPLM8/iecWwiP6xpf5S
PryHTuCZaIcAPqoAIryGn9SwWUlEQkzz5z0/l8ybJZpjeQXq++c6qaWE+uRWeIim
IBGSx8kweHEHy2qzCnSPrc45pU0UTRBcWji7XsXJVToZSxsrqcRytBu9UlcOm8VB
9kCMiIdsqTPG7aEaCxHTfiBU3AUtusPYjIY3VNXQHk/CpcqN/T19JO7aaG0rroGI
D5yl1Afmy22xD/c95o+Q8rtxBfqFmBiltNHktyAsPi5o9MFbdQtdZ3FqYEHskTFk
Ia8cJZsdmf0eVqHVVNGR
=smmk
-----END PGP SIGNATURE-----

--=-zC7eTGCNtDeX7ZGFAIvU--
