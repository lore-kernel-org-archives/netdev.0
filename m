From: Mck <mick@semb.wever.org>
Subject: bnep module in 2.6.27 fails to provide bnep0 device
Date: Sat, 03 Jan 2009 02:20:14 +0100
Message-ID: <1230945613.10187.13.camel@localhost>
References: <20081229131222.5C2902F889@sch-sesat01.dev.osl.basefarm.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-h+TtZuaV9vv0lZcIZ35F"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:60297 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757423AbZACCPG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Jan 2009 21:15:06 -0500
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1LIw2Z-00088K-4Z
	for netdev@vger.kernel.org; Sat, 03 Jan 2009 02:15:03 +0000
Received: from wever.org ([83.243.151.80])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 03 Jan 2009 02:15:03 +0000
Received: from mick by wever.org with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 03 Jan 2009 02:15:03 +0000
In-Reply-To: <20081229131222.5C2902F889@sch-sesat01.dev.osl.basefarm.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-h+TtZuaV9vv0lZcIZ35F
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

This used to work for me but after some system updates is now broken.

I'm using the following combination on gentoo:

 linux-2.6.27 (64-bit)
 bluez-libs-3.36
 bluez-utils-3.36

Restarting bluetooth with the usb dongle in gives in the system log:

[hcid] Bluetooth HCI daemon
[hcid] Parsing /etc/bluetooth/main.conf failed: No such file or directory
[hcid] Starting SDP server
[hcid] Unix socket created: 11
[hcid] Registered manager path:/org/bluez/audio
[hcid] Registered input manager path:/org/bluez/input
[hcid] Starting experimental netlink support
[kernel] pan0: Dropping NETIF_F_UFO since no NETIF_F_HW_CSUM feature.
[hcid] Failed to find Bluetooth netlink family
[hcid] Can't init plugin /usr/lib64/bluetooth/plugins/netlink.so
[hcid] bridge pan0 created
[hcid] Registered manager path:/org/bluez/network
[hcid] Registered server path:/org/bluez/network/nap
[hcid] Registered server path:/org/bluez/network/gn
[hcid] Registered server path:/org/bluez/network/panu
[hcid] Registered manager path:/org/bluez/serial
[hcid] HCI dev 0 registered
[hcid] HCI dev 0 already up
[hcid] Device hci0 has been added
[hcid] Starting security manager 0
[hcid] Device hci0 has been activated


Then running "pand -c XX" I get:

[pand] Connecting to 00:19:63:14:8C:6C
[hcid] link_key_request (sba=3D00:10:60:D1:7C:31, dba=3D00:19:63:14:8C:6C)
[pand] bnep0 connected
[/etc/init.d/net.bnep0] ERROR: interface bnep0 does not exist
[/etc/init.d/net.bnep0] Ensure that you have loaded the correct kernel modu=
le for your hardware
[/etc/init.d/net.bnep0] ERROR: net.bnep0 failed to start


It seems pand connects through the bnep0 device, and indeed the mobile
phone i'm connecting to registers the connection and itself connects to
the 3g network, but the kernel complains...

I'm quite lost here and hoping anybody would be kind enough to help.

~mck

--=20
"Microsoft has done for software what McDonald's did for the hamburger."
PC MAGAZINE, June 1997=20
| semb.wever.org | sesat.no | sesam.no |

--=-h+TtZuaV9vv0lZcIZ35F
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)

iEYEABECAAYFAklevU0ACgkQkdPrePiuutPbvACdGtY2cfw8PvaarQ6Uer/kILKQ
zxcAnRviGrlsmc2puNan893fX+RzHeRo
=srfW
-----END PGP SIGNATURE-----

--=-h+TtZuaV9vv0lZcIZ35F--


