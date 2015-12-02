From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] i40e: Fix i40e_print_features() VEB mode output
Date: Wed, 02 Dec 2015 01:56:55 -0800
Message-ID: <1449050215.3224.29.camel@intel.com>
References: <1448475679-57194-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1448475679-57194-5-git-send-email-jeffrey.t.kirsher@intel.com>
	 <5655FD72.70902@cogentembedded.com> <1448476535.3021.5.camel@intel.com>
	 <1448480194.20113.48.camel@perches.com>
	 <1449002936.1593.10.camel@perches.com> <1449041100.3224.17.camel@intel.com>
	 <1449045535.3716.10.camel@perches.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-b/wt0MMDmyEr3szsJBDJ"
Cc: netdev <netdev@vger.kernel.org>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Shannon Nelson <shannon.nelson@intel.com>
To: Joe Perches <joe@perches.com>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:59045 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756450AbbLBJ5I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Dec 2015 04:57:08 -0500
In-Reply-To: <1449045535.3716.10.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-b/wt0MMDmyEr3szsJBDJ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-12-02 at 00:38 -0800, Joe Perches wrote:
> Commit 7fd89545f337 ("i40e: remove BUG_ON from feature string
> building")
> added defective output when I40E_FLAG_VEB_MODE_ENABLED was set in
> function i40e_print_features.
>=20
> Fix it.
>=20
> Miscellanea:
>=20
> o Remove unnecessary string variable
> o Add space before not after fixed strings
> o Use kmalloc not kzalloc
> o Don't initialize i to 0, use result of first snprintf
>=20
> Noticed-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Don't you mean Reported-by? =C2=A0I am not aware of Noticed-by as being a
recognized signature.

> Signed-off-by: Joe Perches <joe@perches.com>
> ---
> =C2=A0drivers/net/ethernet/intel/i40e/i40e_main.c | 42 +++++++++++++----
> ------------
> =C2=A01 file changed, 19 insertions(+), 23 deletions(-)

--=-b/wt0MMDmyEr3szsJBDJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJWXsBnAAoJEOVv75VaS+3ODxgP/jsh6fG2DquhlsU+uzOIOuPR
RkP2el5mQxVMQvupelhlGYwDVqnXL3gbmH4szXbZ6L1joaX9oVMKpBg/ORPNGEHn
Gr5eIF29WxUlryzr5nWnUHMY5P7XC8EyBlYLibX5nXBIaz6S5TmChUo0Jg1jqxP5
eixBX3czW5YOcIVNxCx/YfgEg6nnEPFFwU0G44Ob18VtZ8aoZ4jXYLswbFpOdy9Z
3sRjKjqeDZHDYjrpn7zjFRNrZCJxKROTJprc7by41491zGsWEZHBGIhjc5uPh4nd
X14l0U50E35s/DtnMWla/0y7APLfbbOoMiwMErXfMWFHLSZZCYmKw4L2MsUdO6AV
G5WVTwrQlCBlzK+wZ7k28b0asSGAnbUCuAblpsezkKgn3AGwrVVz5Yj5Hs40jik+
RbgKlIFlQSlg5xnW2WIsh4UlUeNf4LVfC0/l4797xoh9/pqne67HMQiBfQQyGHaL
X4sxBg7qC0UGBEn9hpuWlCsakQFlP4xvJwMp7mQBTqV8hIKmmfjVGfVSSGmv90Gg
wplIEO6uPfWvKaDmKGHSYbuz/omxhgZVH4yXtTf0kSIT8SMdOrAyNkv98C88nVOB
6jHNSZdkCROBuzerUPmc2fpCqhUg+E473soYeUCUhKeE1EGTmi6ThuHPNFzlxIgg
5XPnIxrdxWCLvHOYlI0/
=3Rta
-----END PGP SIGNATURE-----

--=-b/wt0MMDmyEr3szsJBDJ--
