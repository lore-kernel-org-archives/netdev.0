From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next PATCH v3 4/5] fm10k/igb/ixgbe: Replace
 __skb_alloc_page with dev_alloc_page
Date: Tue, 11 Nov 2014 09:28:24 -0800
Message-ID: <1415726904.2466.170.camel@jtkirshe-mobl>
References: <20141111172523.16460.16845.stgit@ahduyck-vm-fedora20>
	 <20141111172657.16460.60596.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-/CM4ciqIHuKOmYPsgMLT"
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	leedom@chelsio.com, hariprasad@chelsio.com,
	donald.c.skidmore@intel.com, oliver@neukum.org, balbi@ti.com,
	matthew.vick@intel.com, mgorman@suse.de, davem@davemloft.net
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:65057 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751152AbaKKR25 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2014 12:28:57 -0500
In-Reply-To: <20141111172657.16460.60596.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-/CM4ciqIHuKOmYPsgMLT
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-11-11 at 09:26 -0800, Alexander Duyck wrote:
> The Intel drivers were pretty much just using the plain vanilla GFP
> flags
> in their calls to __skb_alloc_page so this change makes it so that
> they use
> dev_alloc_page which just uses GFP_ATOMIC for the gfp_flags value.
>=20
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: Matthew Vick <matthew.vick@intel.com>
> Cc: Don Skidmore <donald.c.skidmore@intel.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
> ---
>  drivers/net/ethernet/intel/fm10k/fm10k_main.c |    2 +-
>  drivers/net/ethernet/intel/igb/igb_main.c     |    2 +-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    3 +--
>  3 files changed, 3 insertions(+), 4 deletions(-)

Thanks Alex, I will add the patch to my queue.

--=-/CM4ciqIHuKOmYPsgMLT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUYkc4AAoJEOVv75VaS+3Ox0EQAIGhc4BUmf6Uy0w8BN5y2XGt
E8p53VgEn3FAxSyj9cf/UW9QjH01EbyiZZAreBmJ5yJiXWxsQZFAdpG2rlhrUHUl
Fs1HfNWuZ7K+4QyNfToUuti0XVJ9gIdS9cydbpXobtgz9w1bzMrifNw8kkEA9l1R
ApFX1pu9mNWhDXbTO/RuQdBhjAZZz16AQ3RBnAW0680Ths/CSFUStthh4q+abLl7
VRCp5MjKtMoneOQNHQuSKZe01qgya7lOpCH2mKkRSjy45tc89eNCOByOnFGxBTxh
FY28YrDETwCpo5pv/cQtfEbo0b68kpsSU32mWpvuNTaKNAMRcO2hzA0ZdjhR+LOD
8FKN4CbeNS0xtZAxVLyvVUiQU+ubxFb/pKzuD19qQ3/h5MGUBCmmD0/b796GiRza
tW285ls7LmAh4X/vPNreYJC8FSf7EB/lqcjPQPqaoPuS/ryrHsw2tqs7R83VkZBZ
lDGlzAcE9Ed+xR503XRl7H7rYXIcr0LN05DRgDecW7kGV7YNjZL/o5/QuB/8fn16
4oP5KOlSRXz5F9uQMxgzFpcydIVflj8agoeFOBGzU6mRjNZ9vLUMsfSVK8ZghcYK
Q5n9Rn8+OjrQ/H8whOkH9YSbZ+bBpYKfQx1ZBLQaCfq4yuRBAMAj44J1wLl9YqEX
9yv9SNFSssT20UyfW/5M
=1Cbu
-----END PGP SIGNATURE-----

--=-/CM4ciqIHuKOmYPsgMLT--
