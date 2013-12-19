From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 00/15][pull request] Intel Wired LAN Driver Updates
Date: Thu, 19 Dec 2013 11:20:36 -0800
Message-ID: <1387480836.2183.42.camel@jtkirshe-mobl>
References: <1387434891-19719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-4rMYEzVeY89C6i17zhGf"
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:48035 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753911Ab3LSTUh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Dec 2013 14:20:37 -0500
In-Reply-To: <1387434891-19719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-4rMYEzVeY89C6i17zhGf
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2013-12-18 at 22:34 -0800, Jeff Kirsher wrote:
> This series contains updates to i40e only.
>=20
> Anjali provides a patch to prevent messages from stray HMC events,
> except
> at interrupt message level, and refactors the HMC error handling.
>=20
> Catherine adds routines in probe to populate/check PCI bus speed and
> width,
> then verify we are in a 8GT/s x8 PCIe slot and warn when we are not.
>=20
> Shannon adds Wake-on-LAN support for i40e, fixes curly brace use as
> well as
> return type for i40e_vsi_clear_rings().  Lastly implements the
> set_settings
> and set_pauseparam ethtool functionality.
>=20
> Joseph implements receive offload for VXLAN for i40e, where the
> hardware
> supports checksum offload/verification of the inner/outer header.
>=20
> Mitch provides the bulk of the changes, where he refactors the VF
> reset
> code so that it works on real hardware.  Then does code cleanup by
> calling existing functions to enable and disable queues for VFs and
> remove unused functions.  Removes a unnecessary log messages that are
> seen at every VF reset, for example complaining about disabling queues
> that are already disabled.  Fixes an error return when the VF asks to
> add an invalid MAC address and if the VF sends a bad message, make it
> more informative about what is actually going on.
>=20
> Jesse refactors the LED function to flash LED lights correctly.
>=20
> The following are changes since commit
> 020e867c755610fa5a2a08a69707e636cf368b55:
>   isdn: use strlcpy() instead strcpy()
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next
> master

Dave-
Disregard this pull request.  I overlooked a patch that needs to either
precede this series or get added to the series for VXLAN.

I will be sending out a v2 with the necessary patch added.

Cheers,
Jeff

--=-4rMYEzVeY89C6i17zhGf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABCgAGBQJSs0cEAAoJEOVv75VaS+3OlwEP/R0iKFQAHGMzfpxwtyo5Xgs2
2J4yHUqt+9l1aLEophqEkGzlCi1zF2XGMQdm8KBlgrPpBpwBoevyDxamWXRkZ5xu
UbPVLHeOUyv0loE7WL5fwhpjg6FJ16A9SRrHM2gymrEDbtEVz4jXtmtlkCxqF8PV
7apkZWxE/BdqOs18VUeZQzqzauRsoI6O7tfLrCfmEQz8t5PpuUKBYysYVHE8IEdK
cUhED+pAYE8ItxpFIuhMuCIuOQ0T60lHavtOgwOxxUXLFaAsoCYgIA4K/ldsWY5A
OP9uqdQj0jFP+HIjOcpYa34zFZEr04toKvQ+8c8xPdXLzCGhzfVcNINNcplrz9Iv
A9fSSvk3/V5IVK3UC9zIYR6ijZDhHDxO+SK3NmyXkvSUftpRnpBBbSd8x5SkD1Lm
T+i7+q/SdLg7cahI0udARe5S570R+BbOMMoxdGLfa9IfjtGLEG9YR5P/uMrao+rn
FOBJbnsTtFZ4BumUmUeYRbnyK52a4WLayQpq2T9KeFz9+prIbNtzvsdzJAS8mX+x
aEDLLsjUo+uppdW/9JWXTVf+K91K+9jGfMPvgpusB4krgZPiyZ/2DwpO2Mxz8pWS
3xkN4D1wemBqJY9HvTtaAB9jObU4stwv4kMAsDCKK6SAkLRsX3XR7KiClCXHEs77
cE91dv+MkiCxzBpmtGjq
=AGWb
-----END PGP SIGNATURE-----

--=-4rMYEzVeY89C6i17zhGf--
