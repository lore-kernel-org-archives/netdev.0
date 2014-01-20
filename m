From: Daniel Exner <dex@dragonslave.de>
Subject: Poor network performance x86_64.. also with 3.13
Date: Mon, 20 Jan 2014 23:27:25 +0100
Message-ID: <52DDA2CD.9040001@dragonslave.de>
References: <52DAD66F.7080306@dragonslave.de> <20140118195026.GA15543@pd.tnic> <52DB0439.2060905@dragonslave.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Borislav Petkov <bp@alien8.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f172.google.com ([209.85.215.172]:51878 "EHLO
	mail-ea0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751452AbaATW1b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jan 2014 17:27:31 -0500
Received: by mail-ea0-f172.google.com with SMTP id g15so2791928eak.31
        for <netdev@vger.kernel.org>; Mon, 20 Jan 2014 14:27:30 -0800 (PST)
In-Reply-To: <52DB0439.2060905@dragonslave.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA512

Hi,

Am 18.01.2014 23:46, schrieb Daniel Exner:
> Hi again,
>=20
> Am 18.01.2014 20:50, schrieb Borislav Petkov:
>> + netdev.
> Thx
>=20
> Am 18.01.2014 20:49, schrieb Holger Hoffst=C3=A4tte:> [This mail was
> also posted to gmane.linux.kernel.]
>=20
>> On Sat, 18 Jan 2014 20:30:55 +0100, Daniel Exner wrote:
>=20
>>> I recently upgraded the Kernel from version 3.10 to latest=20
>>> stable 3.12.8, did the usual "make oldconfig" (resulting
>>> config attached).
>>>=20
>>> But now I noticed some _really_ low network performance.
>=20
>> Try: sysctl net.ipv4.tcp_limit_output_bytes=3D262144
>=20
> Tried that. Even 10 times the value. Same effect.


I just did the same procedure with Kernel Version 3.13: same poor rates=
=2E

I think I will try to see of 3.12.6 was still ok and bisect from there.

Greetings
Daniel
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCgAGBQJS3aLFAAoJEPI6v6bI/Qkf9+4QAJkfljUsRQn6DA6gWy3XYsn4
ZB3F2Mu8kLsCMVjpASsi7+km2qTiFv4qGOgezHCJmqMcdCFszBweGQrnYBLA5PCD
XSZ7G4S0U71aHWtY6iQd1q4ywnA21pfnGRqIpc5+OuIiIOm+YY+RXpJAHC5y1OVo
MxsPL1ZVp/enJoZuvblw6i+JT+soAbSypPWcNQ78qb+CYzLVMLZHcqQvMwpAsRvQ
LNKx8nyj8p32CdZo1GoT3f/nWvBeh/V/ViLrtt64u/oXMJyk5INVRFpSNUUviP8c
42y+r2K31+nY11K2dHsdJYbv5lZ8p8g0SNoLG1SrjgDspaptnT8jptxxn7GcQqdL
PZ3waUB7qYU15IxCA2iXwNPqjtsv8V5l55H/cunKQgxNbb318ui/a3cW7+R++CeL
onv9HFNUkHJiP/MvZJ1/FXE0AsjX70un9NuQ0+xFjCRwJ/YLZzCHkWMERcev500O
vS1yFTGiVY1HndoA4VFYzEkjOyHgDHHQA+0JkfBspVlhL7ow9hccmULZtEn9LzwU
9rooQHyXwdKr6KIbsjHECyjIsBhW4Jfj6195bZ9ddBDBXSqYyGqjiuy7l7TjlZVa
YmPNTlkEfMeXkO2h3km8TD2f+MPntYXkYjZVVUcK8NucgnIdLuWDk/GLrt73VTd8
Cww6B/u4YnGJSF5v/nit
=3DxCa3
-----END PGP SIGNATURE-----
