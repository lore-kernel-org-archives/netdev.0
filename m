From: Robin Getz <rgetz@blackfin.uclinux.org>
Subject: Re: 802.1Q support?
Date: Tue, 13 Jan 2009 11:54:07 -0500
Message-ID: <200901131154.07729.rgetz@blackfin.uclinux.org>
References: <200901121148.26905.rgetz@blackfin.uclinux.org> <200901130731.20538.rgetz@blackfin.uclinux.org> <200901131429.41178.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "Florian Fainelli" <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail11.analog.com ([137.71.25.57]:24826 "EHLO
	nwd2mail11.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752827AbZAMQyE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 11:54:04 -0500
In-Reply-To: <200901131429.41178.florian@openwrt.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue 13 Jan 2009 08:29, Florian Fainelli pondered:
> Le Tuesday 13 January 2009 13:31:20 Robin Getz, vous avez =C3=A9crit=C2=
=A0:
> > Great - That looks like the way to go -- is there any plan in sendi=
ng this
> > to mainline?
>=20
> Yes we will definitively submit it for mainline inclusion, Felix, who=
 wrote=20
> the swconfig stuff will probably want to clean it up a bit and/or add=
=20
> features.
>=20
> Lennert Buytenhek also proposed a Distributed Switch Architecture whi=
ch is=20
> worth looking at, though it does not cover more "classical" switches=20
> connection over GPIO, SPI or special PHY address.

Hmmm ...=20
https://kerneltrap.org/mailarchive/linux-netdev/2008/9/25/3411164/threa=
d

> The switch driver presents each port on the switch as a separate
> network interface to Linux, polls the switch to maintain software
> link state of those ports, forwards MII management interface
> accesses to those network interfaces (e.g. as done by ethtool) to
> the switch, and exposes the switch's hardware statistics counters
> via the appropriate Linux kernel interfaces.

This exposes eth[n] for every port - and these are managed by the stand=
ard=20
userspace tools?=20

That seems like it would be more intuitive for end users -- wouldn't it=
?
