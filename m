From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [PATCH 04/26] rt2x00: EEPROM 93Cx6
Date: Fri, 8 Dec 2006 21:00:10 -0500
Message-ID: <200612082100.14592.flamingice@sourmilk.net>
References: <200612031919.05228.IvDoorn@gmail.com> <200612031339.28148.flamingice@sourmilk.net> <200612081956.14158.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1193024.TKOSXMlCtf";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:53866 "EHLO
	annwn14.rutgers.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S936279AbWLICAk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Dec 2006 21:00:40 -0500
To: Ivo van Doorn <ivdoorn@gmail.com>
In-Reply-To: <200612081956.14158.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1193024.TKOSXMlCtf
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Friday 08 December 2006 13:56, Ivo van Doorn wrote:
> I have checked the adm80211 code as well, it seems to behave quite the
> same, with the most notable difference the fact that adm80211 writes the
> READ_OPCODE and the word index within a single command, while in
> eeprom_93cx6 this is split into 2 seperate write commands.
> I have not yet tested the exact impact for rt2x00 devices when they would
> combine the write commands, but if that has no impact (or the adm80211
> suffers no impact when the write commands are being split) then rt2x00 and
> adm80211 could indeed share the eeprom_93cx6 module.
Hm, which way is the correct way? (is there a correct way?)

> If eeprom_93cx6 is moved to the /lib folder of the kernel, should it be
> approved by a different maintainer first?
>
I don't think so, but I'm not sure. BTW, I think there can actually be anot=
her=20
user of this code. Take a look at drivers/scsi/aic7xxx/aic7xxx_93cx6.c

I'm not sure who the maintainer for this is. Should be okay to just have=20
adm8211 and rt2x00 using eeprom_93cx6 for now, unless you have a spare=20
aic7xxx supported device lying around. ;)

Thanks,
=2DMichael Wu

--nextPart1193024.TKOSXMlCtf
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFehiuT3Oqt9AH4aERAjfHAJ9SE0uK3YNOafLEB4i+fHTl327XKACfbwaH
+uoXTC02U48s7HZObkObhpY=
=vjhU
-----END PGP SIGNATURE-----

--nextPart1193024.TKOSXMlCtf--
