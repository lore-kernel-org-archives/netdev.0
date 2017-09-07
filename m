From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net 1/2] i40e: Fix comment about locking for
 __i40e_read_nvm_word()
Date: Wed, 06 Sep 2017 18:16:11 -0700
Message-ID: <1504746971.3922.83.camel@intel.com>
References: <cover.1504684488.git.sbrivio@redhat.com>
         <4d27bbb33031ac1489fe6d969edd74d44155136c.1504684488.git.sbrivio@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
        protocol="application/pgp-signature"; boundary="=-ZCtMd78DIHK3LyweDoqg"
Cc: "David S . Miller" <davem@davemloft.net>,
        Anjali Singhai Jain <anjali.singhai@intel.com>
To: Stefano Brivio <sbrivio@redhat.com>, netdev@vger.kernel.org,
        intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:9801 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751267AbdIGBQ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 6 Sep 2017 21:16:29 -0400
In-Reply-To: <4d27bbb33031ac1489fe6d969edd74d44155136c.1504684488.git.sbrivio@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ZCtMd78DIHK3LyweDoqg
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2017-09-06 at 10:11 +0200, Stefano Brivio wrote:
> Caller needs to acquire the lock. Called functions will not.
>=20
> Fixes: 09f79fd49d94 ("i40e: avoid NVM acquire deadlock during NVM
> update")
> Signed-off-by: Stefano Brivio <sbrivio@redhat.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_nvm.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Yes, this fixes the function header comment, not sure if it requires
the "Fixes:" tag.  If that were the case, wonder why all the other code
comment changes do not have this. :-)  I do agree it reads better with
this change, so I do not have an issue queue this up for Dave's net
tree.
--=-ZCtMd78DIHK3LyweDoqg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiTyZWz+nnTrOJ1LZ5W/vlVpL7c4FAlmwndsACgkQ5W/vlVpL
7c4zKRAApApzdRuHoYz4WBCT2YSa4CHM10DrFeEYUfdM5WfNnOwMPZ3E/j03MQRz
QbwCp6Andbf/wMBJspK63HYs/6cQjdXcip94zi8FYAQUMJMcslSbqmEUS+Zv8Oyb
mbu5GaxtVg41rXg01HnJBQC+cm6iSnug6dyDDQB+DUe2cg6/2tf4PHUKQVtOLMPi
O0RkZPhcZL4QSz0SQcbUEShPffbjUKZBPcQ7XPLQBtRfVLb+KRQ8zpFA5N2Qhr3M
tvRTIJ2Ft1ohDfTMBxRn1PeSm3zmZxrnRCDsW/tqq3iSlKgaFJ2fEQRJ/2EkttJj
8IZ9vNCIaaDDxWLxbTU0k+5+DHAKbQXigv2Qn4tM+juEfxPIKwR7nwD20Z/1kAYs
1OLieQFZlpAJXvTQBZsrcxV2/jmx8qxpJACXRyNlfKlmZBm1XWhdnj3iFAOP840z
hbQebRW73ApNT8HowjcX5dI/+yg8uR076Rxb5Qz1uLHkk9CVS1TonBkYWRbbOkm8
3wk3mZjfW83Q8hXvfaMBBBGN6rMRBBrYY2+vIUZtBCZNRz8oYhUrF0atL9Tqkgj5
std4RBRlVvTnqtLIkus3nB7repOou8Qdi+gm/Hh8IowIeOgyesSDSr6d5jZzg30w
/hB51M1iCfYT603omDmngh1xPXJmUNj/2VkEzC9k7hDMyRcXSl8=
=MZZy
-----END PGP SIGNATURE-----

--=-ZCtMd78DIHK3LyweDoqg--
