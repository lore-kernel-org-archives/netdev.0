From: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
Subject: Re: 3.0.0rc6: ethtool not working without a cable
Date: Wed, 6 Jul 2011 16:53:04 +0200
Message-ID: <201107061653.04689.a.miskiewicz@gmail.com>
References: <201107061338.08573.a.miskiewicz@gmail.com> <1309962484.4280.25.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f52.google.com ([209.85.161.52]:59521 "EHLO
	mail-fx0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753145Ab1GFOxJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 10:53:09 -0400
Received: by fxd18 with SMTP id 18so161971fxd.11
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2011 07:53:07 -0700 (PDT)
In-Reply-To: <1309962484.4280.25.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 06 of July 2011, Ben Hutchings wrote:
> On Wed, 2011-07-06 at 13:38 +0200, Arkadiusz Miskiewicz wrote:
> > 3.0.0rc6, thinkpad t400 notebook.
> >=20
> > If there is no cable then ethtool reports no device. It wasn't that
> > before AFAIK.
> >=20
> > ethtool version 2.6.36
> >=20
> >=20
> > cable disconnected:
> >=20
> > [root@t400 ~]# ethtool eth0
> > Settings for eth0:
> > Cannot get device settings: No such device
> > Cannot get wake-on-lan settings: No such device
> > Cannot get message level: No such device
> > Cannot get link status: No such device
> > No data available
> > zsh: exit 75    ethtool eth0
> > [root@t400 ~]# ethtool -i eth0
> > Cannot get driver information: No such device
> > zsh: exit 71    ethtool -i eth0
>=20
> [...]
>=20
> Then there really isn't a device under that name.  Maybe the driver i=
s
> getting a bogus MAC address, so that the device is renamed by udev.

No, no, device exists:

[arekm@t400 ~]$ ip l
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast =
state=20
DOWN qlen 1000
    link/ether 00:21:86:a2:19:06 brd ff:ff:ff:ff:ff:ff
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc sfq state UP =
qlen=20
1000
    link/ether 00:16:eb:05:5d:08 brd ff:ff:ff:ff:ff:ff
[arekm@t400 ~]$ ethtool eth0
Settings for eth0:
Cannot get device settings: No such device
Cannot get wake-on-lan settings: No such device
Cannot get message level: No such device
Cannot get link status: No such device
No data available
zsh: exit 75    ethtool eth0
[arekm@t400 ~]$


--=20
Arkadiusz Mi=C5=9Bkiewicz
