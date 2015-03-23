From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next v6 7/7] ixgbevf: Add the appropriate ethtool
 ops to query RSS indirection table and key
Date: Mon, 23 Mar 2015 03:31:53 -0700
Message-ID: <1427106713.2577.164.camel@jtkirshe-mobl>
References: <1427050887-19412-1-git-send-email-vladz@cloudius-systems.com>
	 <1427050887-19412-8-git-send-email-vladz@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-kxyOKYYpXY5UpXMJGEZP"
Cc: netdev@vger.kernel.org, avi@cloudius-systems.com,
	gleb@cloudius-systems.com
To: Vlad Zolotarov <vladz@cloudius-systems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:55853 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752159AbbCWKbz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Mar 2015 06:31:55 -0400
In-Reply-To: <1427050887-19412-8-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-kxyOKYYpXY5UpXMJGEZP
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2015-03-22 at 21:01 +0200, Vlad Zolotarov wrote:
> Added get_rxfh_indir_size, get_rxfh_key_size and get_rxfh ethtool_ops
> callbacks
> implementations.
>=20
> This enables the ethtool's "-x" and "--show-rxfh[-indir]" options for
> VF devices.
>=20
> Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
> ---
> New in v6:
>    - Added a required get_rxnfc callback to ixgbevf_ethtool_ops.
>=20
> New in v4:
>    - Removed not needed braces in if-statement in
> ixgbevf_get_rxfh_indir_size().
>=20
> New in v3:
>    - Added a proper support for x550 devices: return the correct
> redirection table size.
>=20
> New in v2:
>    - Added a detailed description to the patch.
>=20
> Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
> ---
>  drivers/net/ethernet/intel/ixgbevf/ethtool.c | 58
> ++++++++++++++++++++++++++++
>  1 file changed, 58 insertions(+)

Thanks Vlad, I have applied your patch to my next-queue tree
--=20
git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue.git
dev-queue

--=-kxyOKYYpXY5UpXMJGEZP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVD+uZAAoJEOVv75VaS+3OhFUP/AqXV//LWIz3k/nd+9/r5c5y
rGujZX7Gp1UYCZZ3t4b1zk8LImoYNy/hWsRgYgU0PcWOiucydEsKb2+rTebKfbPf
oAO5wq3/ZmGRP2xP5RBE+PRKqVRzw7qmtpQwxc7wHTu0TLNK3A3G4PyU9hFxWULn
hA7X/u31P13aQBkGLkzMWaUPsnZARJHLWFf4UjFgKh/wkh7N7F+bLOV6eFIWvxvb
ebJslue+JcZs9VXq+/7t1+vVkBYt3/gO8K+ZccaehvpASZH4fzZKSbavitJ6c3pr
hfFVDHxizovxH+e8sSLuYdE7/balrjICUT9hLnP19+QPIWX/afN1Yx7J65ytbn/h
gcbksRlJOzdIHMh9bhr8el8r9jNN74W47zlTWo5jESGg6xqHmsnW8L0tBBmlikkA
1R9zTM+ckBamJipSOjNex7Xz2JYxOBABRxB5L9d9edlWYFAXeVinhuEO5MQ7UkXL
ui0GquPxrVAaEXv4yJ8kmBZmc44pyyFDkW8oWVQq4DCnptAkuOKY0Jk3BjXChG2F
7oXYGikYPbt54QXM1ieXYjlh+HNnQwDUGtM7d1nUGgwG5A6vM1JqudzxXKM8xNrK
6XuvsFb7+Ultlji5lmMHphDuP/5TVz6AnNkvYI31ogvXIyaQLvENPo//6sy38vjY
05ZIebCCgKRKEmpzrUNK
=P+wp
-----END PGP SIGNATURE-----

--=-kxyOKYYpXY5UpXMJGEZP--
