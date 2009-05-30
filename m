From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usbnet: ratelimit warning messages invoked from
 callback handler
Date: Fri, 29 May 2009 22:14:17 -0700 (PDT)
Message-ID: <20090529.221417.259461953.davem@davemloft.net>
References: <b8bf37780905270940k7523d0of337111dcb80861@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: petkan@users.sourceforge.net, shemminger@vyatta.com,
	dbrownell@users.sourceforge.net, netdev@vger.kernel.org
To: andre.goddard@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57937
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753400AbZE3FOR convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 May 2009 01:14:17 -0400
In-Reply-To: <b8bf37780905270940k7523d0of337111dcb80861@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Andr=E9 Goddard Rosa <andre.goddard@gmail.com>
Date: Wed, 27 May 2009 13:40:44 -0300

>     usbnet: ratelimit warning messages invoked from callback handler
>    =20
>     Warning messages coming from rtl8150 driver can flood the console
>     and make a DTV/set-top-box unable to decode video/audio frames.
>    =20
>     'Pegasus' driver handles this situation similarly, preventing thi=
s
>     from happening there.
>    =20
>     It happens with a low cost BCM MIPS embedded platform, whenever
>     timeout errors were coming from usbnet device, making platform
>     unusable for viewer watching.
>    =20
>     Signed-off-by: Andr=E9 Goddard Rosa <andre.goddard@gmail.com>
>=20

Applied to net-next-2.6, thanks.
