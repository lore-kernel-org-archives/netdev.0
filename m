From: Jeff Kirsher <tarbal@gmail.com>
Subject: Re: [PATCH v3 2/4] net: Handle encapsulated offloads before fragmentation
 or handing to lower dev
Date: Fri, 07 Dec 2012 15:15:54 -0800
Message-ID: <50C278AA.6020902@gmail.com>
References: <1354845419-22483-1-git-send-email-joseph.gasparakis@intel.com> <1354845419-22483-3-git-send-email-joseph.gasparakis@intel.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="------------enig6DF46FBF22522B3C5EA03758"
Cc: davem@davemloft.net, shemminger@vyatta.com, chrisw@sous-sol.org,
	gospo@redhat.com, Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dmitry@broadcom.com, saeed.bishara@gmail.com
To: Joseph Gasparakis <joseph.gasparakis@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:27248 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754701Ab2LGXP4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Dec 2012 18:15:56 -0500
In-Reply-To: <1354845419-22483-3-git-send-email-joseph.gasparakis@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig6DF46FBF22522B3C5EA03758
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 12/06/2012 05:56 PM, Joseph Gasparakis wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
>
> This change allows the VXLAN to enable Tx checksum offloading even on
> devices that do not support encapsulated checksum offloads. The
> advantage to this is that it allows for the lower device to change due
> to routing table changes without impacting features on the VXLAN itself=
=2E
>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> ---
>  net/core/dev.c       |   15 +++++++++++++--
>  net/ipv4/ip_output.c |    4 ++++
>  2 files changed, 17 insertions(+), 2 deletions(-)
Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>


--------------enig6DF46FBF22522B3C5EA03758
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with undefined - http://www.enigmail.net/

iQIcBAEBCgAGBQJQwniqAAoJEOVv75VaS+3ODBUP/1tcHnL5NmfppIhChwX3s9eL
8L7a01GiqKK80Ez/S9ZUzfnmXgS5w3HILO1RyfjXiU+QjT9IkDYd0tnwM6rqvTaq
eVW9mEXgNTzNxHSTmbeqpHIqOHhIqNaeEdOW26GZgJGt0n0CMOBcLTFZhGFvD3ZD
/8sEmxTRrIqnrShxux82RxoEyWDqX75CBfkB+Bx6nwwYZSnpQ3EmTtQ+c/92b0th
b/PH7XUQ0/HQfD+JN+MF/O654ID9iafAjdP6UyGvKhQmZ1ya9JceDz/oatzQUKRz
W+DlupjW1Y/K8VNa2tXnvS/KcqI8RJmslgWj5t/tWbZle8M9ujSU9spcVs5fPwqs
ov2tcynq+Kv/sjPxiGyFAkQw+QxnicwbaOe4p+OyFG0MT3UhmtTUosLNleXWAaJo
hlToNFh2BAZQAHJJ07t+6lk5eobG4/6G1pZ1NJr2APElD9FY5s723y2udUS4Jq/+
ZY72FjNNpHn2C7rTd2Ls4tDLxBPnAi8y7y79eHDLscFBDUzBt+Iny8Q1l30HYXPY
a19FHEVo3jpMmzUBb6ZNCquWWFs1G43TMmXbV1winoN33+9z5lk+TaWSO5rpXu+i
khuOOTkvtnkNF5MZRgjYCFN1T8vPrP9eNAeoEn6Hogo35/42+Fub+Rqp/Jl2G2dB
kcAGNKBpJN5ckGBxJur/
=3ZH9
-----END PGP SIGNATURE-----

--------------enig6DF46FBF22522B3C5EA03758--
