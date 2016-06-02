From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v2 5/6] ethernet/intel: Use
 pci_(request|release)_mem_regions
Date: Thu, 02 Jun 2016 14:01:35 -0700
Message-ID: <1464901295.2736.29.camel@intel.com>
References: <cover.1464795082.git.jthumshirn@suse.de>
	 <e15aedde3b7d8b301b9ca6197f8d39d4076c9c86.1464795082.git.jthumshirn@suse.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-V2PqDfR0o+AxeTcExJxv"
Cc: linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org,
	Christoph Hellwig <hch@infradead.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org
To: Johannes Thumshirn <jthumshirn@suse.de>,
	Bjorn Helgaas <bhelgaas@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <e15aedde3b7d8b301b9ca6197f8d39d4076c9c86.1464795082.git.jthumshirn@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-V2PqDfR0o+AxeTcExJxv
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2016-06-02 at 09:30 +0200, Johannes Thumshirn wrote:
> Now that we do have pci_request_mem_regions() and
> pci_release_mem_regions() at
> hand, use it in the Intel ethernet drivers.
>=20
> Suggested-by: Christoph Hellwig <hch@infradead.org>
> Signed-off-by: Johannes Thumshirn <jthumshirn@suse.de>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Cc: intel-wired-lan@lists.osuosl.org

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

> ---
> =C2=A0drivers/net/ethernet/intel/e1000e/netdev.c=C2=A0=C2=A0=C2=A0 |=C2=
=A0 6 ++----
> =C2=A0drivers/net/ethernet/intel/fm10k/fm10k_pci.c=C2=A0 | 11 +++--------
> =C2=A0drivers/net/ethernet/intel/i40e/i40e_main.c=C2=A0=C2=A0 |=C2=A0 9 +=
++------
> =C2=A0drivers/net/ethernet/intel/igb/igb_main.c=C2=A0=C2=A0=C2=A0=C2=A0 |=
 10 +++-------
> =C2=A0drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |=C2=A0 9 +++------
> =C2=A05 files changed, 14 insertions(+), 31 deletions(-)

--=-V2PqDfR0o+AxeTcExJxv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXUJ6vAAoJEOVv75VaS+3OAGQP/jXZHPJWhfwdV91AxtxXpMNV
dJVvKKBCLY4j1EJBtcIE1ZzqLDLfVInQE8xVX6LwTh+dAg6nzLjir1RSrR4qkjFd
u3JDIkdYzi4T2CE7Wh34Hn+fMtD+cLbwExpqnm7rY3nN9oLg6MSpfuftaxaQRvea
VcffdWLjcz9nn+6d01LKa2k37i5/ijAbEcWOInUZ71fYvNh1v8ZYHYPKPgnhBsbJ
8ZpT7miRtkBGX2e2DiwJZqvb/+byrB/NxhvyjeuN10ow8XkyvR1xPebHB87tI6M6
qyQXolFcHUjQ1rncWpWGWFxbBa2cChENK5G+ni/Esdr1y9ebrja21gkHxD9UKnnT
5XP1Bsb/n6KsdGMMSCfop+UWrtLtZteRYrGABvicQdo6aJXQCQ6O7ZsaQMBUakhw
3ut5WMAwb/EhHsgpqOZHZU2qpj5FMmupIH2lM+1bX1GAIcJl4xbD2VU2+TtXAd6a
Xi1RObsDElRop6ZA05H4DrI59nitxM9aAjonWG7mSvQJL8xAznb6sIYazjg7lF69
OxePtJbtpWviWuf4MBVBFEa39zZcGhTivjxzkrYYq0+cYvfNdOVBL3AhW5g6c9c8
8lh6cUcM/ZQpa4hoDB2wwLi9/JRI1OQCRiuBCmOdVMigxrjnOcyPlvp9WRbZ2Pvu
Pcds1/QA+1E1Ow0QZL87
=hp3V
-----END PGP SIGNATURE-----

--=-V2PqDfR0o+AxeTcExJxv--
