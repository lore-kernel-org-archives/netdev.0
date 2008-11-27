From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 10/39] wimax: Generic messaging interface between user
	space and driver/device
Date: Thu, 27 Nov 2008 10:55:23 +0100
Message-ID: <1227779723.3809.43.camel@johannes.berg>
References: <cover.1227691434.git.inaky@linux.intel.com>
	 <802197ab7fc27af2e6e36ab83039cad6569997e1.1227691434.git.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-ZGPDI9j+YtrBOCeSgUfz"
Cc: netdev <netdev@vger.kernel.org>
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:58139 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752377AbYK0J4P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 04:56:15 -0500
In-Reply-To: <802197ab7fc27af2e6e36ab83039cad6569997e1.1227691434.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ZGPDI9j+YtrBOCeSgUfz
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2008-11-26 at 15:07 -0800, Inaky Perez-Gonzalez wrote:
> This implements a direct communication channel between user space and
> the driver/device, by which free form messages can be sent back and
> forth.
>=20
> This is intended for device-specific features, vendor quirks, etc.
>=20
> Currently is the only communication mechanism used because there is no
> standard kernel API defined for WiMAX operation. Not enough devices
> are in the market to decide what is a good user-kernel API/abstraction
> layer.

Obviously I don't like this, reminds me too much of iwpriv. What kind of
messages are you passing now? What would be wrong with defining those
things you need now as actual commands, and then later
extending/modifying the command set when new hardware shows up?

That's what we're doing in cfg80211, simply adding commands as we go
along and not everybody has to support all commands, ultimately. You can
always even query the supported command set via the genl controller.

> +struct genl_ops wimax_gnl_msg_from_user =3D {
> +	.cmd =3D WIMAX_GNL_OP_MSG_FROM_USER,
> +	.flags =3D 0,

same thing with permissions here

johannes

--=-ZGPDI9j+YtrBOCeSgUfz
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJLm6IAAoJEKVg1VMiehFYvSkP/2bnfEG2vTpCW/jlFrXVxCzz
fDirQBugw4KABy6Rir7wstUW9NE0vlMcObRqRboPUiP+nnEmYhlZuOViDXLvgihR
FMC/cz3BLPwdQAAAghZzZCGqN93TWyKavRRWaXQMwHv2N0ddWDVbEAkpr0R0tLkz
bjzh7KVUSZ9VbBNUdXhO9G0/PFSa7bGZEiFJsaalui6JfyTrm1UqXb5yrnlc74SK
jPHru6IlcjsElVncTlNLbI9rKr3G7UAs6Dek7k0rJQXmhA7zVA1KNLlOOelU7o2l
RKafMxC3/XKrRtWe3SYab/p2U+4li/SfQJiTnC7ze0g67XSb0sumj73fYBimazni
9aIoSOqiM33pRvN0O2nHcpCF894Gae2Bp0ZebGdk5qGL7dZG+X9AA7mB1HU+2fP9
3f/W9X8b9Tnx+WVV65sxti29ic+E4vkpUISQjhLbGneSukcFKuK9xR53iR+NlujQ
/KUuq+SyDVXnWnZGomVHiDxgE8LSKORGF/YXdr/fYlJHiE1+vPAL6nkG2136QQ6z
GnVoGWWt0IYUTkDqf5OJRfQuQBdsgXGWFVbvoMi+9oUkDYRPb+5OPKtPJ3KnziLR
yFW3tgfP8E7U79aZ5T3GabqRlej1sDDnpSbnrZd/iv3xZ67ZIWmorXaPkwmEFWHn
lwJ8oh+nln+ecun28z7s
=F4RK
-----END PGP SIGNATURE-----

--=-ZGPDI9j+YtrBOCeSgUfz--

