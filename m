From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [net-next 01/13] e1000e: Fix no connectivity when driver loaded
 with cable out
Date: Fri, 18 Apr 2014 14:15:46 +0100
Message-ID: <1397826946.3624.32.camel@deadeye.wl.decadent.org.uk>
References: <1396308899-20926-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1396308899-20926-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-IVX3FkqaZNKSzTApHEwT"
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	David Ertman <davidx.m.ertman@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:42037 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754022AbaDRNP6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2014 09:15:58 -0400
In-Reply-To: <1396308899-20926-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-IVX3FkqaZNKSzTApHEwT
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-03-31 at 16:34 -0700, Jeff Kirsher wrote:
> From: David Ertman <davidx.m.ertman@intel.com>
>=20
> In commit da1e2046e5, the flow for enabling/disabling an Si errata
> workaround (e1000_lv_jumbo_workaround_ich8lan) was changed to fix a probl=
em
> with iAMT connections dropping on interface down with jumbo frames set.
> Part of this change was to move the function call disabling the workaroun=
d
> to e1000e_down() from the e1000_setup_rctl() function.  The mechanic for
> disabling of this workaround involves writing several MAC and PHY registe=
rs
> back to hardware defaults.
>=20
> After this commit, when the driver is loaded with the cable out, the PHY
> registers are not programmed with the correct default values.  This cause=
s
> the device to be capable of transmitting packets, but is unable to reciev=
e
> them until this workaround is called.
[...]

Which devices are affected by this?  I just did a backport of e1000e
from 3.13 for Debian 7.5 and didn't spot this fix until later.

I couldn't reproduce this problem on my laptop, which has:

00:19.0 Ethernet controller [0200]: Intel Corporation 82579LM Gigabit Netwo=
rk Connection [8086:1502] (rev 04)

Ben.

--=20
Ben Hutchings
Lowery's Law:
             If it jams, force it. If it breaks, it needed replacing anyway=
.

--=-IVX3FkqaZNKSzTApHEwT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAU1Elgue/yOyVhhEJAQrX/A//agFa6W0SvUI4YSx26qzvUs9OyN0cft2N
JEVrTShbbaZPAIrxYFmn8xg+WeGgB3W22HTBY1cnhzYNRy5qqI1MZXvdbIYsNFvn
mry0NK+OWt5KAKb7h8t3LcMf9GFMFsDNySaamA++xHN1eYVUXHdS+H9oh3yml1Iy
c6CKJdBu+Cq2CBYXHpRzBkegBqWQ4wKBWa7ysJKll7S6VNXqKnvec8vehpVI3tsH
Xx7v/Y7YnDuyKoyi29qQfqQIweroUKR/q9fOIJZ9zv3dgJBsIKv2cQzD8cKJP6QG
8qszVS0jHvKH/DtsskCbRCaEfP1pGICasXMCDq1WIGLZvMszhjU+Azfdom9Lntyh
Ecs6nRhyb2h3swXc2ZhXsdGNeI9lZ6ILIF1rkREvjppKMBuyXOTg8QJkMKzio6/O
Le4W2Ul650YyaR8V2ovXmtAmdr7lcQd66Tjf7OgT8LBvwVpDlnO+OP04c9kBBNGu
NRJAToY/CAZg8J7R1V4BMMZs0EXDqkU+cDqMm6Crzd2Y/erl90Hx6dNqMKkGlFHq
giutUQHwAsgSj3nBMVJYgg3juP0CkKf5OvKP8MSZO5BWwdg2E631j7ru7JoGIdny
S5VC/l8az/f9cgGCelohDBoitR/jEuLyLmspjn+04ISzGK5Co67EoAQtdpJ7PQ7u
GqtbGmqoU6U=
=RHxC
-----END PGP SIGNATURE-----

--=-IVX3FkqaZNKSzTApHEwT--
