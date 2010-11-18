From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Devices with colon in name (iproute2 bug)
Date: Thu, 18 Nov 2010 15:09:41 +0100
Message-ID: <1290089381.2781.139.camel@edumazet-laptop>
References: <AANLkTimw7=zS8YNptNNP9YR0v93EwctBvsG58a4z+Y-M@mail.gmail.com>
	 <1290086705.3818.63.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?=C5=A0tefan_Sakal=C3=ADk?= <rabbit6440@gmail.com>,
	netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:41327 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758404Ab0KROJq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Nov 2010 09:09:46 -0500
Received: by wwa36 with SMTP id 36so3378719wwa.1
        for <netdev@vger.kernel.org>; Thu, 18 Nov 2010 06:09:45 -0800 (PST)
In-Reply-To: <1290086705.3818.63.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 18 novembre 2010 =C3=A0 13:25 +0000, Ben Hutchings a =C3=A9cri=
t :

> Linux originally only supported one address per address-family per
> interface.  Additional addresses had to be assigned to 'alias
> interfaces' which were named <base-interface>:<index>.  For backward
> compatibility, colons in interface names are reserved for this purpos=
e.
> If you can create regular interfaces with colons in their names, this
> seems to be a kernel bug.

Yes

Speaking of kernel bug, many devices dont set operstate, while they
really are UP

-> UNKNOWN

# ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN=20
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP q=
len 1000
    link/ether 00:21:70:b0:e4:89 brd ff:ff:ff:ff:ff:ff
3: wlan0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state D=
OWN qlen 1000
    link/ether 00:23:4e:1a:49:2d brd ff:ff:ff:ff:ff:ff
4: virbr0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue sta=
te UNKNOWN=20
    link/ether 3e:42:f7:21:de:e2 brd ff:ff:ff:ff:ff:ff
6: vboxnet0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen =
1000
    link/ether 0a:00:27:00:00:00 brd ff:ff:ff:ff:ff:ff
7: ppp0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc pfifo=
_fast state UNKNOWN qlen 3
    link/ppp=20


