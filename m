From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] i40e: Fix i40e_print_features() VEB mode output
Date: Thu, 03 Dec 2015 04:13:46 -0800
Message-ID: <1449144826.3224.46.camel@intel.com>
References: <1448475679-57194-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1448475679-57194-5-git-send-email-jeffrey.t.kirsher@intel.com>
	 <5655FD72.70902@cogentembedded.com> <1448476535.3021.5.camel@intel.com>
	 <1448480194.20113.48.camel@perches.com>
	 <1449002936.1593.10.camel@perches.com> <1449041100.3224.17.camel@intel.com>
	 <1449045535.3716.10.camel@perches.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-P7WcjuBRqi9g0U6r6+EZ"
Cc: netdev <netdev@vger.kernel.org>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Shannon Nelson <shannon.nelson@intel.com>
To: Joe Perches <joe@perches.com>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:21437 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757526AbbLCMNs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 07:13:48 -0500
In-Reply-To: <1449045535.3716.10.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-P7WcjuBRqi9g0U6r6+EZ
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
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
> =C2=A0drivers/net/ethernet/intel/i40e/i40e_main.c | 42 +++++++++++++----
> ------------
> =C2=A01 file changed, 19 insertions(+), 23 deletions(-)

Your patch does not apply cleanly, it appears you used Dave's net-next
tree to generate your patch, versus my next-queue tree (dev-queue
branch) which has a number of i40e patches already applied.

As a one-time only reminder, I have gone ahead and applied your patch
by hand. =C2=A0I will send your updated patch out here in just a minute.
--=-P7WcjuBRqi9g0U6r6+EZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJWYDH6AAoJEOVv75VaS+3OiXQQAIgL1WRwkwW5mstdskiojULZ
UKCtPJSX5CI/igz/+Z9dnbOfnLaNNS37A0XVpmbWeY65dzgsehns8zJL4YkqY7KB
fb5qBZ+m+JKGlbHizdXpOUrJqtlM9GUN+B9Ip8FnnR4oSaCAJIo8KH29B9G9OP0j
gj7a89636N+YzlbBLydAWGyFvv5y4qhy+S6EkWGQMIT1N/sSOulJl/AHaHIKAbWZ
X+Bf0S3thhJQtR9Q6xigk3Rs5PjoOFJfbAyjkp7ynXdiP2GLLc0wcW3U0yzOcLBN
dCdSbegxNh3I/UXj+9U5q2oQSXLmNZJgO1YffeSeIXrtp34QugcRsd4hScc12EJV
VgcBNK4JY0elWsIo4wL1oVx1rreY1tl3w7hDN8agxmrY8gZAqepMbkNDda8U1kHi
iF9G/Bj2eGVack5eqlbiFF1j2opHAYanI33ajPi269/nGugvRa11+x96x1PsyB0E
g/iA9INnlZEpk660yqFD5e+oDxwX7g9wvExW7BXcTggwDmxiKi+PjFj5B57U/Aob
3bc6evf7ueugPI/r9FGS6Q1l6VMyms/goNAJZ/4d1uAxgMM0qFMWzc1HU+TVhQ00
WqBA9HoYjSaNQhT7/H+aHLcqLsjPS7i4Q+xJ2ztHnkOxNbyebaFUhLu31CTKEeWZ
5spI8ZfV1HZy00KziAyw
=NxGi
-----END PGP SIGNATURE-----

--=-P7WcjuBRqi9g0U6r6+EZ--
