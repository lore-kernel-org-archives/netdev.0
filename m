From: Jeff Kirsher <tarbal@gmail.com>
Subject: Re: [PATCH 4/4] e1000e: Not initialize the e1000_ps_page array when
 packet-split is not used
Date: Mon, 20 May 2013 02:38:07 -0700
Message-ID: <5199EEFF.3070905@gmail.com>
References: <1369037707-27026-1-git-send-email-weiyang@linux.vnet.ibm.com> <1369037707-27026-5-git-send-email-weiyang@linux.vnet.ibm.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="------------enigF7544034234A112838216E07"
Cc: jeffrey.t.kirsher@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Wei Yang <weiyang@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:6649 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752097Ab3ETJiP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 May 2013 05:38:15 -0400
In-Reply-To: <1369037707-27026-5-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigF7544034234A112838216E07
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 05/20/2013 01:15 AM, Wei Yang wrote:
> When packet split is not used, those fields are still initialized and m=
emory
> is allocated for them.
>
> This patch check whether packet split is used and do the initialization=
 base
> on the status.
>
> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
> ---
>  drivers/net/ethernet/intel/e1000e/netdev.c |   38 ++++++++++++++------=
-------
>  1 files changed, 20 insertions(+), 18 deletions(-)
Thanks, I have added the patch to my queue for e1000e.


--------------enigF7544034234A112838216E07
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)
Comment: Using GnuPG with undefined - http://www.enigmail.net/

iQIcBAEBCgAGBQJRme8AAAoJEOVv75VaS+3O57YP/3s7IfY5YNzg8nj/RjrheFM4
Zf1wTtAc6xOE2JCKecLBlDPQKu3CbfNyHl27iSITPu77GMp6yYYmWcb8/CP/pG2a
kIJB+QFE4oZw/2mTm8zObzDWDpoCbFwRgqo60Okgi1nSPyKTQ6QUPuX3l/YjQx2Q
c9YYmYBB9IqGUozZPCcNr/V+eV9lyowTHly7XnwVSKPsOrgHSM5Pn27hWLHJmTBC
9y/90FBDjSwLFQBYfJFthChYGhSFMxH3pfWPNowde5+6ZXXm+VuZZYMO3f2WvNlB
5/BLfPscbs+5W8oKHPmGRZopqus0oBMGH2igA737Db9Of8bALONgdJ4lLW7Gl71y
7tzfL51zbK0RljMHORd+SNJIIcBtyCcJ3cIke6B68RtASKJQ2ZnIWRfqb6zz3uCj
w4GHVj/Ut2KqZ3B+v61WHy7Une4xSW5evPNGWfPPOs/xnCQfLR6shipgReso1iDL
MI+sN48EotXuucprDgjCpzfosnVgcXmWn0aFih035+5T6R6zAML8T7eNfCbiQ5C0
eVPOyM8AkXb5ojbnfnOieXfXR62R/G21hr31T2Z3B+0mhhnJRZmJPvHT1H/JJTMb
7jL8JHU9rU9gWcsEvCIYjFiQx0EDq6PpHdfGxfa5ToFpk6UJxFKTkShLsoz3DpQF
DKTM6//1CjAwXY8g8peW
=fWK4
-----END PGP SIGNATURE-----

--------------enigF7544034234A112838216E07--
