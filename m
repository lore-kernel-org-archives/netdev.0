From: Jeff Kirsher <tarbal@gmail.com>
Subject: Re: [PATCH] e1000e:  MSI interrupt test failed, using legacy interrupt
Date: Thu, 26 Apr 2012 17:20:35 -0700
Message-ID: <4F99E653.4000608@gmail.com>
References: <1335485150-2765-1-git-send-email-prasanna.panchamukhi@riverbed.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="------------enig7071E7F709ADE0CF66074FC1"
Cc: bruce.w.allan@intel.com, jeffrey.t.kirsher@intel.com,
	jeffrey.e.pieper@intel.com, bhutchings@solarflare.com,
	gospo@redhat.com, sassmann@redhat.com, jesse.brandeburg@intel.com,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: prasanna.panchamukhi@riverbed.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:48877 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754520Ab2D0AUh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2012 20:20:37 -0400
In-Reply-To: <1335485150-2765-1-git-send-email-prasanna.panchamukhi@riverbed.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig7071E7F709ADE0CF66074FC1
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 04/26/2012 05:05 PM, prasanna.panchamukhi@riverbed.com wrote:
> From: Prasanna S. Panchamukhi <ppanchamukhi@riverbed.com>
>
> Following logs where seen on Systems with multiple NICs & ports,
> while using MSI interrupts as shown below:
>
> Feb 16 15:09:32 (none) user.notice kernel: 0000:00:0d.0: lan0_0: NIC Li=
nk is Up
> 1000 Mbps Full Duplex, Flow Control: RX/TX
> Feb 16 15:09:32 (none) user.notice kernel: 0000:40:0d.0: wan0_1: NIC Li=
nk is Up
> 1000 Mbps Full Duplex, Flow Control: RX/TX
> Feb 16 15:09:32 (none) user.notice kernel: 0000:40:0d.0: lan0_1: NIC Li=
nk is Up
> 1000 Mbps Full Duplex, Flow Control: RX/TX
> Feb 16 15:09:32 (none) user.warn kernel: 0000:40:0e.0: wan4_0: MSI inte=
rrupt
> test failed, using legacy interrupt.
> ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> Feb 16 15:09:32 (none) user.notice kernel: 0000:00:0e.0: wan1_0: NIC Li=
nk is Up
> 1000 Mbps Full Duplex, Flow Control: RX/TX
> Feb 16 15:09:33 (none) user.notice kernel: 0000:00:0e.0: lan1_0: NIC Li=
nk is Up
> 1000 Mbps Full Duplex, Flow Control: RX/TX
> Feb 16 15:09:33 (none) user.notice kernel: 0000:00:0f.0: wan2_0: NIC Li=
nk is Up
> 1000 Mbps Full Duplex, Flow Control: RX/TX
> Feb 16 15:09:33 (none) user.notice kernel: 0000:00:0f.0: lan2_0: NIC Li=
nk is Up
> 1000 Mbps Full Duplex, Flow Control: RX/TX
> Feb 16 15:09:33 (none) user.notice kernel: 0000:40:0a.0: wan3_0: NIC Li=
nk is Up
> 1000 Mbps Full Duplex, Flow Control: RX/TX
> Feb 16 15:09:33 (none) user.notice kernel: 0000:40:0a.0: lan3_0: NIC Li=
nk is Up
> 1000 Mbps Full Duplex, Flow Control: RX/TX
> Feb 16 15:09:34 (none) user.notice kernel: 0000:40:0e.0: lan4_0: NIC Li=
nk is Up
> 1000 Mbps Full Duplex, Flow Control: RX/TX
> Feb 16 15:09:34 (none) user.notice kernel: 0000:40:0f.0: wan5_0: NIC Li=
nk is Up
> 1000 Mbps Full Duplex, Flow Control: RX/TX
> Feb 16 15:09:34 (none) user.notice kernel: 0000:40:0f.0: lan5_0: NIC Li=
nk is Up
> 1000 Mbps Full Duplex, Flow Control: RX/TX
>
> This patch changes the IRQ tests to use polling loops starting with a
> delay of 1 tick and doubling that if necessary up to a maximum total
> delay of approximately 1 second.
>
> Signed-off-by: Prasanna S. Panchamukhi <ppanchamukhi@riverbed.com>
> ---
>  drivers/net/ethernet/intel/e1000e/netdev.c |   27 ++++++++++++++++++++=
+++----
>  1 files changed, 23 insertions(+), 4 deletions(-)
Thanks Prasanna, Dave did accept the previous patch, so does this patch
take that into account?



--------------enig7071E7F709ADE0CF66074FC1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQIcBAEBCgAGBQJPmeZUAAoJEOVv75VaS+3OHpIP/1ejShVRu2TumVNio37CDyw8
STKjuF/0f+rF3bCummg+MNPgS0DWoKnBvaVPkx22uSnQRc3STHMLU1svl1DOz2tH
YekWff9DE8pSIu9FgVFfje7Hz+Buj/e3AB7pstrRwYCDpSjlz8j1DsBfPk0VttOA
nUw98mMMVy3h15CzOnNCoZP9Es99moH1P2DUVIa+LWdGlZah5ZTiKzaEkGQviFxf
1wVu8hroaKGxfkVcvHvOeKL7/Q0ZlpvVJYBF8c7N9exrcalHRucCcwSr72xHXd62
BY9jlC+Hirsf5zsZjH625aASH2zGveDJxyWuDNtcAs2PiNOWK5+AtQlw2C76rQBN
KdstaqdnPhYqwaWStdn2xhHei6Ywls45xttIC4QgWnKvdOGfdDR2SRm720OcDFct
U5ZVKNZpxAelpQMlnsV2JY6Vqoep9G/S+zYDTzZiCpMKX+P4EnEzXo/nSdUzZKjl
Ad64WtyMZTxc2TRmAb2YuaQaEgh6ZTPiDO2P7dkpWDtLTzNf2/mh3b+9LMbyKeTL
muA6R0I89SNoNzKfytz9lOORglsJ5SezgmVr75rtwLudxjl2V6pLsonM+FOku5om
1HaeMMkO2YCC393f6Mx0xd/p1NgBS0d0u6Mq5DNHtcpEdG8bYPwWZBjgYjh5XQx8
ZY3rhLNvWQIvWY4Q+5ap
=g6WQ
-----END PGP SIGNATURE-----

--------------enig7071E7F709ADE0CF66074FC1--
