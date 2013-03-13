From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] igb: SR-IOV init reordering
Date: Wed, 13 Mar 2013 00:51:39 -0700
Message-ID: <1363161099.2099.17.camel@jtkirshe-mobl>
References: <20130312212533.19552.92159.stgit@bling.home>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-bdvXE9+oBTXnoj8HQCHQ"
Cc: gregory.v.rose@intel.com, netdev@vger.kernel.org,
	ddutile@redhat.com, linux-kernel@vger.kernel.org,
	sassmann@redhat.com
To: Alex Williamson <alex.williamson@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130312212533.19552.92159.stgit@bling.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-bdvXE9+oBTXnoj8HQCHQ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2013-03-12 at 15:25 -0600, Alex Williamson wrote:
> igb is ineffective at setting a lower total VFs because:
>=20
> int pci_sriov_set_totalvfs(struct pci_dev *dev, u16 numvfs)
> {
>         ...
>         /* Shouldn't change if VFs already enabled */
>         if (dev->sriov->ctrl & PCI_SRIOV_CTRL_VFE)
>                 return -EBUSY;
>=20
> Swap init ordering.
>=20
> Signed-off-by: Alex Williamson <alex.williamson@redhat.com>
> ---
>  drivers/net/ethernet/intel/igb/igb_main.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)=20

I have added the patch to my igb queue, thanks!

--=-bdvXE9+oBTXnoj8HQCHQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJRQDALAAoJEOVv75VaS+3OIREQAJDpWbjN+3mgxMTaealS7Xp9
kcRi4BWFXL4BZ7kKoPtv2CumZrr6iLfnvlIegrPTFd/wUU8O1KfroDAX4yX1jL5j
d8Rpvj05WYjEbZRehDM41wUVgdiJuT5YkyXupO1XgocO5ylETvSydl2vuPw4bu3I
LNSJelOIbovZTvihue8LsnPBQl52xqt3lrHpkWMUYPrBWGnhsHf3l3So0BGflwgV
ouxRwy/kQYIGqnuAzbPjuJCfwsMq7sdfhJPOqeXTOgGc4//VHHy1a0lSQs7ePqAi
FQcTttH1LHQ6rFRvvlR900q6zgCkNbeGdau5RECX4s/jiXw/ezJKMHZkusUhTpam
b9v4SbYGKSFhUZcDhL5GZ9iqx7fPIuRF5XkMfF56yjAl+DTO1eO7h/YItMDT/z8K
/rva8UvaFTYXMn3k2CCknV4waQ39OsDSO9KwNet6ORElPnpf2EviVkB1817MIK7d
Ag+3hb4lkxcMVJJskAw7tDO8mbiAQP6CX7zUMVNdccqrhpfkMMJFMco0Fc+PlCRL
BMH+O8JU00i+WVS2zgB6KIo9ztKvVlm83LcysM6Z0kDTvcRKNkrX5uMfWZdVRYCx
w/WhdTeVBX++LelT0gKL7oEMY4q3S2xsD4QHZJ66FqRTITn0K7LfdtRcA0weD8cb
BpfQcc/xI3Slf15eNW3+
=pCCR
-----END PGP SIGNATURE-----

--=-bdvXE9+oBTXnoj8HQCHQ--
