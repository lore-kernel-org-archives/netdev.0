From: Cord Walter <cord.walter@gmx.de>
Subject: Re: axnet_cs / pcnet_cs: moving PCMCIA_DEVICE_PROD_ID for Netgear
 FA411
Date: Fri, 21 Nov 2008 15:10:27 +0100
Message-ID: <4926C153.3090104@gmx.de>
References: <4925F6F1.9010305@gmx.de> <20081121214812.b03d7166.komurojun-mbn@nifty.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-pcmcia@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: Komuro <komurojun-mbn@nifty.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sour.ops.eusc.inter.net ([84.23.254.154]:52795 "EHLO
	sour.ops.eusc.inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752029AbYKUOK3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 09:10:29 -0500
In-Reply-To: <20081121214812.b03d7166.komurojun-mbn@nifty.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Komuro schrieb:
> On Fri, 21 Nov 2008 00:46:57 +0100
> Cord Walter <cord.walter@gmx.de> wrote:
>=20
>> after noticing that my Netgear FA411 (PCMCIA-NIC) [1] stopped workin=
g with
>> the release of the 2.6.25 kernel (sidux-version),
>=20
> You are right. My patch has a bug.
> The patch below fixes this problem.
>=20
> By the way,
> (1) Does your FA411 work properly with the pcnet_cs driver before?

Yes, it worked until the 2.6.25 release.

> (2) Please post the full-dmesg (axnet_cs).

This is what I get from dmesg when plugging in the FA411:

pccard: PCMCIA card inserted into slot 1
cs: memory probe 0xa0000000-0xa0ffffff: clean.
pcmcia: registering new device pcmcia1.0
eth0: Asix AX88790: io 0x300, irq 3, hw_addr 00:09:5b:08:98:93
udev: renamed network interface eth0 to eth1
NET: Registered protocol family 17


Does this help?

-cord

--=20
Cord Walter
email: cord.walter@gmx.de

Weil es niemanden etwas angeht, dass ich nichts zu verbergen habe:
http://www.gnupg.org/
http://www.truecrypt.org/
=2E..und =C3=BCberhaupt: http://www.FreiheitstattAngst.de
