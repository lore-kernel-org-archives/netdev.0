From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next v6 1/7] if_link: Add an additional parameter to
 ifla_vf_info for RSS querying
Date: Mon, 23 Mar 2015 03:30:21 -0700
Message-ID: <1427106621.2577.158.camel@jtkirshe-mobl>
References: <1427050887-19412-1-git-send-email-vladz@cloudius-systems.com>
	 <1427050887-19412-2-git-send-email-vladz@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-RVcoh2Gsz8Q4s9iFlXtL"
Cc: netdev@vger.kernel.org, avi@cloudius-systems.com,
	gleb@cloudius-systems.com
To: Vlad Zolotarov <vladz@cloudius-systems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:15466 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752033AbbCWKaX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Mar 2015 06:30:23 -0400
In-Reply-To: <1427050887-19412-2-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-RVcoh2Gsz8Q4s9iFlXtL
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2015-03-22 at 21:01 +0200, Vlad Zolotarov wrote:
> Add configuration setting for drivers to allow/block an RSS
> Redirection Table and
> a Hash Key querying for discrete VFs.
>=20
> On some devices VF share the mentioned above information with PF and
> querying it may
> adduce a theoretical security risk. We want to let a system
> administrator to decide if he/she
> wants to take this risk or not.
>=20
> Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
> ---
>  include/linux/if_link.h      |  1 +
>  include/linux/netdevice.h    |  8 ++++++++
>  include/uapi/linux/if_link.h |  8 ++++++++
>  net/core/rtnetlink.c         | 32 ++++++++++++++++++++++++++------
>  4 files changed, 43 insertions(+), 6 deletions(-)

Thanks Vlad, I have applied your patch to my next-queue tree
--=20
git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue.git
dev-queue

--=-RVcoh2Gsz8Q4s9iFlXtL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVD+s9AAoJEOVv75VaS+3OX3oP/0duSD8bAecvo8j72zPjiqqj
njkzLx03paXrtfYEomWBdvsrI13Hz4MCjoQfDmI3bKv0/pzrVPoSykcXQcviyeUw
cXrgM9JueO2adPa/grdNtHEDOWxeWFkIRQOIIs4040mmztJTTPSkbUkH8aQ1flxw
k6v+xoq0hi0eGfvdq09ufY0JVGextUFl6eGBtLtrn0NIOj/HBT+C/b57sB2KeliP
VnxEWXh+F8/CjyBC+mvZRDRLnkXOt+spiqsGnvMgFpyX6Oy5WPkb9T2APuxhVtJ8
Wl+jf4RCb7Tu8CBvICU6HLJN+IiQ3Hf2+2pMD/Apc0CNGPjvM2jAjFFA0JiMOQYu
9LmNYARjqxAw0X+7az1OXCPxYqZo74n6jrQBqz1JY5rElKsCjhiKGdbj7/nXSFbb
Zhks5Tq+gV3+YVw7BrGjAa06dZXVbKaE3zf2iRQKkOAqKmikK6h3YD19u/hr3l8Y
bnFsXFrPrlElpEr+DuBZSFTHOLUaNoZ+PRw/G9QgvbHrwNqIdrBfvONLcclT+PUj
OjTyAl2vdDUDnzlJdvjdZXrOAJdGda9xdSo9jgm12egMCVy0jaXCYbZkW10i9AMk
wiBV3zqVjEvailDJVpCSRw/zMSRHv75Ymvco73p29AQGWw6VdIRctbxo2ge5pKwV
lkvEW5xYtHGDLu3zf08X
=9eJy
-----END PGP SIGNATURE-----

--=-RVcoh2Gsz8Q4s9iFlXtL--
