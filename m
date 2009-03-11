From: Christer Weinigel <christer@weinigel.se>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Wed, 11 Mar 2009 21:56:06 +0100
Message-ID: <49B82566.3070909@weinigel.se>
References: <1236738549-16703-1-git-send-email-yanok@emcraft.com>	<20090310211841.388619ca@nehalam>	<20090311084430.GU425@pengutronix.de> <20090311.014957.117115597.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: s.hauer@pengutronix.de, shemminger@vyatta.com, yanok@emcraft.com,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	wd@denx.de, dzu@denx.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2-1-3-15a.ens.sth.bostream.se ([82.182.31.214]:40246 "EHLO
	zoo.weinigel.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751428AbZCKVCY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 17:02:24 -0400
In-Reply-To: <20090311.014957.117115597.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:

> From: Sascha Hauer <s.hauer@pengutronix.de>
> Date: Wed, 11 Mar 2009 09:44:30 +0100

 > > [some code to pass the MAC address as module parameters]

> Please remove this code.  If we let you do it, we have to let everyon=
e
> else do it too, and that's something we don't want to do.
>=20
> There are other ways you can handle this, for example have your board
> firmware properly program the MAC address into the card at power-on,
> and then have the driver here look in the MAC address registers to se=
e
> if a valid ethernet address has been left there.


It's still a pain to have to do this.  Many embedded systems that I hav=
e=20
seen have a bootloader which I can't modify to do that, but the=20
bootloader allows me to save the kernel command line into some kind of=20
volatile storage.  S=E5 being able to set the MAC address with a:

     setenv cmdline foo.hwaddr=3D00:de:ad:be:ef:ed

is very nice because it allows me to use a NFS root without having to=20
jump through hoops with initrds an such.

Actually, I wish we had a generic way of doing that, so that could set=20
the mac address of any ethernet interface from the kernel command in a=20
nice and supported way.

   /Christer


