From: Jeff Kirsher <tarbal@gmail.com>
Subject: Re: [PATCH 3/4] e1000e: Calculate the desc_len based on adapter type
Date: Mon, 20 May 2013 02:37:48 -0700
Message-ID: <5199EEEC.5030105@gmail.com>
References: <1369037707-27026-1-git-send-email-weiyang@linux.vnet.ibm.com> <1369037707-27026-4-git-send-email-weiyang@linux.vnet.ibm.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="------------enig52DFA8290DFC5EEAB8FB0079"
Cc: jeffrey.t.kirsher@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Wei Yang <weiyang@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:28262 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753184Ab3ETJht (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 May 2013 05:37:49 -0400
In-Reply-To: <1369037707-27026-4-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig52DFA8290DFC5EEAB8FB0079
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 05/20/2013 01:15 AM, Wei Yang wrote:
> desc_len represents the size of descriptor in rx_ring. There are two ki=
nds of
> rx descriptors, e1000_rx_desc_packet_split(32 byte) and
> e1000_rx_desc_extended(16 byte). Different adapter will use different r=
x
> descriptors.
>
> When allocating the dma space for this descriptor in current implementa=
tion,
> the code ignore the descriptor type and take it as e1000_rx_desc_packet=
_split
> in any case. This behavior will not effect the function, but will requi=
re
> double size of dma space.
>
> This patch will calculate the desc_len based on the adapter type.
>
> Tested on T420, which use e1000_rx_desc_extended and works fine.
>
> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
> ---
>  drivers/net/ethernet/intel/e1000e/netdev.c |    7 ++++++-
>  1 files changed, 6 insertions(+), 1 deletions(-)
Thanks, I have added the patch to my queue for e1000e.


--------------enig52DFA8290DFC5EEAB8FB0079
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)
Comment: Using GnuPG with undefined - http://www.enigmail.net/

iQIcBAEBCgAGBQJRme7sAAoJEOVv75VaS+3OwGkQAKWtpzmVA6XUexPdJExSv15M
EtR2gtIuZTF91sO5r1DowpQYplFCLUa3N67MyKsEihqNEr/i01B5usCUrYkQUbLK
xsMmySoC0RDNkNVaMVvvxecVWhTIY9cf6ch7iyjn8Nsx7JCC7C+OBN83VlggxtBA
klzjLTdy1g8390OJWHhREkl5exPhxFmHN6ymxywMfC8th1T+JceRjnwFSYojEQN5
WzT6ozfhhg9l4E6w553UuxUGNvn7gty3sNFF+0lROovYI6FTF6szdqVFmQn59SkK
FSoVh0WB/yOsyasG4yChRCfFX89SrFLLxukZbLtP+hLRYiTSFETAb1MK+AM9wby/
VfVk3hq7VosMV8kN0ijM+ydjFpuZ+tsfTpQ3jaR1C0dSre+sIQA9LnNgYZzBkPTO
+FDZFYVfduolaUwE6NHmZIAWRulC33hNyC3/U93Vq0gJfJJ6ZmBCkOCzXjQajCxe
yQvEIsoQDW5idQ95Hd9dGNUPZ/L9xbgyOOvNTrIuX4qEruQsMdrWexJspgSz2UCW
hFAuYw5Rk0ZdI0rbd3zpxOAFMtfDDRO3thmh5rgkFV30vbAO5+e0wrhyy6kLCJ9+
Ev1xBK1M+FameHrM9mhSdeX8Uz5C3S/xcWoP3LmdOdOtkll6fjY0SqfAaq1464sO
/0YylgE4C+yPc9eSfjMr
=bNuD
-----END PGP SIGNATURE-----

--------------enig52DFA8290DFC5EEAB8FB0079--
