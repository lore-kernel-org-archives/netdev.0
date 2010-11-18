From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Devices with colon in name (iproute2 bug)
Date: Thu, 18 Nov 2010 13:25:05 +0000
Message-ID: <1290086705.3818.63.camel@localhost>
References: <AANLkTimw7=zS8YNptNNP9YR0v93EwctBvsG58a4z+Y-M@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?Q?=C5=A0tefan_Sakal=C3=ADk?= <rabbit6440@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:49356 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756514Ab0KRNZJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Nov 2010 08:25:09 -0500
In-Reply-To: <AANLkTimw7=zS8YNptNNP9YR0v93EwctBvsG58a4z+Y-M@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-11-18 at 13:14 +0100, =C5=A0tefan Sakal=C3=ADk wrote:
> Hi,
> When I add a device with colon via ip (from git 3f5c1a01):
> ip link add dev 'a:b' type dummy
> then ip link show dev 'a:b' returns
> 12: a:b: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN
> ioctl(SIOCGIFXQLEN) failed: No such device
>=20
> link/ether 9e:44:b4:ec:77:f1 brd ff:ff:ff:ff:ff:ff
>=20
> Also ifconfig from net-tools returns
> a: error fetching interface information: Device not found
> but I guess it's obsolete.

Linux originally only supported one address per address-family per
interface.  Additional addresses had to be assigned to 'alias
interfaces' which were named <base-interface>:<index>.  For backward
compatibility, colons in interface names are reserved for this purpose.
If you can create regular interfaces with colons in their names, this
seems to be a kernel bug.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

