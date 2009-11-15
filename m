From: "=?utf-8?q?R=C3=A9mi?= Denis-Courmont" <remi@remlab.net>
Subject: Re: Phonet userspace bits?
Date: Sun, 15 Nov 2009 18:31:23 +0200
Message-ID: <200911151831.23974.remi@remlab.net>
References: <!256485B18-474275-V2@support.norwegian.no> <1272976626.71600.1258301725789.JavaMail.mail@webmail06>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: dag@bakke.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:54009 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753245AbZKOQbU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Nov 2009 11:31:20 -0500
In-Reply-To: <1272976626.71600.1258301725789.JavaMail.mail@webmail06>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Hello,

Le dimanche 15 novembre 2009 18:15:25 dag@bakke.com, vous avez =C3=A9cr=
it :
> How do an end-user make use of a phonet network interface?
>=20
> Nov 15 16:31:54 toshr500 usb 1-1: New USB device found, idVendor=3D04=
21,
>  idProduct=3D046e Nov 15 16:31:54 toshr500 usb 1-1: New USB device st=
rings:
>  Mfr=3D1, Product=3D2, SerialNumber=3D0 Nov 15 16:31:54 toshr500 usb =
1-1:
>  Product: Nokia 6110 Navigator
> Nov 15 16:31:54 toshr500 usb 1-1: Manufacturer: Nokia
> Nov 15 16:31:54 toshr500 usb 1-1: configuration #1 chosen from 1 choi=
ce
> Nov 15 16:31:54 toshr500 cdc_acm 1-1:1.8: ttyACM0: USB ACM device
>=20
> So I can use /dev/ttyACM0 with pppd and get a 3G connection. so far, =
so
>  good.
>=20
> But what is the usbpn0 network interface, and could I use that instea=
d of
>  fiddling with chatscripts and pppd, to get a 3G connection? Is this
>  feature complete?

Just like with PPP, only the Phonet data path is implemented in kernel.=
 The=20
setup is done in userspace. In theory, it could be done in kernelspace =
too,=20
but there was strong reluctance against this on usb-devel. And well, ma=
ybe we=20
don't want to taint the kernel with too much of the GPRS specifics.

There was a preliminary patch adding the userspace bits to oFono here:
http://lists.ofono.org/pipermail/ofono/2009-September/000376.html
(especially part 0003) but this is still work in progress.

Best regards,

--=20
R=C3=A9mi Denis-Courmont
http://www.remlab.net/
