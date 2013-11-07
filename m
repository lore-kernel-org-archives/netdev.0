From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] ixgbevf: use pci drvdata correctly in ixgbevf_suspend()
Date: Thu, 07 Nov 2013 00:21:24 -0800
Message-ID: <1383812484.2121.34.camel@jtkirshe-mobl>
References: <CAPgLHd8pjBBPwJ+Nn_Ld_YRyd4f_-cxh1U+9ARc5iDRsgXK4-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-InfIRI16zA2iaEKV0NBk"
Cc: jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	gregory.v.rose@intel.com, peter.p.waskiewicz.jr@intel.com,
	alexander.h.duyck@intel.com, john.ronciak@intel.com,
	tushar.n.dave@intel.com, davem@davemloft.net, kaber@trash.net,
	gregkh@linuxfoundation.org, yongjun_wei@trendmicro.com.cn,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:54538 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752945Ab3KGIV3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Nov 2013 03:21:29 -0500
In-Reply-To: <CAPgLHd8pjBBPwJ+Nn_Ld_YRyd4f_-cxh1U+9ARc5iDRsgXK4-A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-InfIRI16zA2iaEKV0NBk
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2013-11-07 at 16:13 +0800, Wei Yongjun wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>=20
> We had set the pci driver-specific data in ixgbevf_probe() as a type
> of
> struct net_device, so we should use it as netdev in ixgbevf_suspend().
>=20
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> ---
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)

Thanks Wei, I will add this patch to my queue.

--=-InfIRI16zA2iaEKV0NBk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABCgAGBQJSe02EAAoJEOVv75VaS+3O6+cP/1ilHdeCVIihX2A/cvCAGxJB
+DYNNDOWvu2Z7RWuRhIOrAqCSTrCoiTu1lWOAOoucEWUoWgv1J2JLd2NKRLSfy30
QXnXEPOsVstn1pH4u35plYEFUltrIjJ/1hvQ8kmIM0gWsUlt8Lf6jJq5tGcoOn7E
y92Y8AsTOBCR0CXnbRy0PktErza0EvKY7LWuU5hJyq4gr4I3yt1ulJcXbM4DM+aN
iYRt6gMdpsO4qfDVKlqadVNPNfPHz1ylXcc3OQbi7Ug5rkRyGKqCWpJR8q80LTa4
5u0hOxiPWSul6v5EsAZWx+LXZjfFWJv0LU/UDK9Du75oBNLN4w/GaBU6HCWRqpU5
zkOfzXoASKGRj3A8XKqTj+rwQf+HL+ZFC2+f9luZ1G3N1ARTHUGeNKzkSY7F8Pmy
YU5YV5qOJqPlmfXd8F6TO8GGGhRh7+Y9zR1q6GFU82LepN8hwOBo1Gg5YkvzcpRs
ggo5vDpI/30qmz7KHuTd4oUJNPqExBMDSE+TlwJI0LFH35VPUdkvlYJE8/ipuiC9
7/cIxZc3iYi2/t8HBwDluuqoEwcA25iooHaEAhSa0s5hL/xjHw9GnTYKXT4XL2F2
2ZL4a73Qz2uFN1RevrwIXNAlKsOuAJ3kpo+zhcnXjvhszg9ayDWYaJBnw/fyzqdE
abKXXdHQqVYApnBBW6bp
=JEpS
-----END PGP SIGNATURE-----

--=-InfIRI16zA2iaEKV0NBk--
