From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next v10 6/7] ixgbevf: Add RSS Key query code
Date: Tue, 31 Mar 2015 00:36:13 -0700
Message-ID: <1427787373.2497.114.camel@jtkirshe-mobl>
References: <1427740529-9605-1-git-send-email-vladz@cloudius-systems.com>
	 <1427740529-9605-7-git-send-email-vladz@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-FsBBsfO9wQaDfweObSwt"
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	avi@cloudius-systems.com, gleb@cloudius-systems.com
To: Vlad Zolotarov <vladz@cloudius-systems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:6376 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751879AbbCaHgO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Mar 2015 03:36:14 -0400
In-Reply-To: <1427740529-9605-7-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-FsBBsfO9wQaDfweObSwt
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2015-03-30 at 21:35 +0300, Vlad Zolotarov wrote:
> Add the ixgbevf_get_rss_key() function that queries the PF for an RSS
> Random Key
> using a new VF-PF channel IXGBE_VF_GET_RSS_KEY command.
>=20
> This patch adds the support for 82599 and x540 devices only. Support
> for other
> devices will be added later.
>=20
> Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
> ---
> New in v10:
>    - Expose the _locked function in the vf.h interface according
>      to the current ixgbevf layering model.
>    - Return EOPNOTSUPP in cases then operation is not supported.
>=20
> New in v9:
>    - Reduce the support to 82599 and x540 devices only.
>    - Added IXGBEVF_RSS_HASH_KEY_SIZE macro.
>=20
> New in v8:
>    - Protect a mailbox access.
>=20
> New in v6:
>    - Return a proper return code when an operation is blocked by PF.
>=20
> New in v2:
>    - Added a more detailed patch description.
>=20
> New in v1 (compared to RFC):
>    - Use "if-else" statement instead of a "switch-case" for a single
> option case
>      (in ixgbevf_get_rss_key()).
> ---
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf.h |  1 +
>  drivers/net/ethernet/intel/ixgbevf/mbx.h     |  1 +
>  drivers/net/ethernet/intel/ixgbevf/vf.c      | 54
> ++++++++++++++++++++++++++++
>  drivers/net/ethernet/intel/ixgbevf/vf.h      |  1 +
>  4 files changed, 57 insertions(+)

Thanks Vlad, applied to my queue.
--=20
git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue.git
dev-queue

--=-FsBBsfO9wQaDfweObSwt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVGk5tAAoJEOVv75VaS+3OrRYP/0T4fVsp8EIeFpqihFs7M5nS
e4XVlPmCNk6mOSIjqnqbT81wGY5dg1rKqm+hOZ72WgIbTpCsyGAy2BM6WxPtfPat
NYea+U77DnQHiOJuBQEAafJ7QvNTD3FSMxFyAZ5b8nf79vDJoUgXeU4XMkYKSc1P
ygnbs0+x7u2JJ75ESxJNDn2U01rc4ikwzWjn8uxabFCIxQv5MhqP2hYnyo4YqjW7
g07dRolN2ncINzOkd987CQMjVZo/U5O2gkiJUA2Kg4vBmMLolSpwEuew5hqeogwR
T5rwpgsIlaBfjmIV0BkLZvpjwTQBkWF272KywHp33PdDP38VCTu5Cd1JxcQiNbyi
I9i6ApYyoQ3KUyUvSyV1TPht/dlhdwHJgfswWZeZvXThNdVqPt6Xe0gLEYqrG3Yb
IgLDeGj8JbEo0h4RdBeEo/AlvCMDiN1F1gll+MYUZIdIOGMaJvtR0NyOHhYd2Qkv
H//ZhYHeY5u6J66O1/I9BkNjByLbfWpsvDhrtdFN9irwAuGanHoRRn/kXb4IpSlg
X7oiWsr1QVoAR//ePdAt+chqkCrkYCtEQsw0ilpX4I7qOFzDjmd1oj18ussAB0xm
CBYxtqspQjjeyivLBXcJPNcI9jZYmWysLeii1sZ5kxmeed9bIIT7UGWZvkcebn8f
5vKVOR5cb1wAzc+/tyvD
=73mT
-----END PGP SIGNATURE-----

--=-FsBBsfO9wQaDfweObSwt--
