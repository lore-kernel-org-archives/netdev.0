From: Jeff Kirsher <tarbal@gmail.com>
Subject: Re: [net-next 0/6 v3][pull request] Intel Wired LAN Driver Updates
Date: Mon, 17 Oct 2011 17:15:40 -0700
Message-ID: <4E9CC52C.6030902@gmail.com>
References: <1318896767-5374-1-git-send-email-jeffrey.t.kirsher@intel.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="------------enig9AF041448BC33C5D4AB7E95C"
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:24749 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751438Ab1JRAP5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Oct 2011 20:15:57 -0400
In-Reply-To: <1318896767-5374-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig9AF041448BC33C5D4AB7E95C
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 10/17/2011 05:12 PM, Jeff Kirsher wrote:
> The following series contains updates to ixgbe, igbvf and igb.
> This version of the series contains the following changes:
>
> - igb fix/add check if subordinate VFs are assigned to VM's
> - igbvf fix for trunk VLAN
> - ixgbe 2 fixes for ethtool and 1 endianess fix
>
> -v2 update the igb patch to resolve a variable initialization warning
> -v3 Drop patch 5 (ixgbe: add hardware time stamping support)
>
> The following are changes since commit fd38f734cb8200529e281338514945fc=
bff2364b:
>   igbvf: convert to ndo_fix_features
> and are available in the git repository at
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next.git
>
> Emil Tantilov (3):
>   ixgbe: fix endianess when writing driver version to firmware
>   ixgbe: allow eeprom writes via ethtool
>   ixgbe: change the eeprom version reported by ethtool
>
> Greg Rose (2):
>   igbvf: Fix trunk vlan
>   igb: Check if subordinate VFs are assigned to virtual machines
>
>  drivers/net/ethernet/intel/igb/igb.h             |    3 +
>  drivers/net/ethernet/intel/igb/igb_main.c        |  177 ++++++++++++++=
++++----
>  drivers/net/ethernet/intel/igbvf/netdev.c        |    4 +-
>  drivers/net/ethernet/intel/ixgbe/ixgbe.h         |    3 +-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c   |    2 +
>  drivers/net/ethernet/intel/ixgbe/ixgbe_common.c  |   16 +-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   84 ++++++++++-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |    7 +-
>  8 files changed, 246 insertions(+), 50 deletions(-)
>
Grrr, forgot to update the title of the cover page.  It *should* be
"net-next 0/5 v3]..."


--------------enig9AF041448BC33C5D4AB7E95C
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQIcBAEBCgAGBQJOnMU3AAoJEOVv75VaS+3OVpgP/0qKLglznvOx7OoY/mmA4y+M
NkBC1GixuLMUkvlhFmqai607y+61eTKyBYEPnmMxAB4QAfX5RJXxYVz3Iml+WmAL
DXwf49CwXj29/VKftSNFxIJwoSuf5E/uGKALI/XS4FWwUMd+2EC5UcYdLJoRv4A+
yHZxCL5t9etQ8dkR/m0VOtsZWwZzju95/lhnK6aygdIgdm3WXBU1iZwEsAkJsrMQ
RlqkTgnkLYJNOG44F77buVoJwpXZZPp4CPa2rDVFlaLJ2WUXhWcw7KmFfuRokajt
VHglt82jNQjMYCv6LbZ8oYHGANqi9ljxkBARvyhXc8AJ2dfbklTvPABK0wn93SaX
HEVHCD+zLJmZ++mYCDXPmvHvWg2F6qcATZekjFlapJdni7SYyFvLUTCG1tHilUoY
v22kQo9G0dwfE3+BLHhmn2nnHBx+6bG4xscOOE2a0Q1fOkAWsWbGMlaR9PbBoiL9
dWwOhmsaDY1QjfatfHjBxIVCC/VtRUHQ0DOkWDW8FyuqGlaAV5uOR9WcMxD/qkk3
xVUrYlnWv/4puJ8864moJpL/reDNCU/t5gM+pCA/pG5alva+Qt+OaXH/EyWosS3v
v+f8DSSmEZLlLMMgFiM3J/4nKsB0Mdcycarf+yEMLo2gLuLTCN1ogjseSSAoHA4Z
zW6clwPiY+dgTAjy7ntJ
=u/el
-----END PGP SIGNATURE-----

--------------enig9AF041448BC33C5D4AB7E95C--
