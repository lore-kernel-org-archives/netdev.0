From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: b53: switchdev driver for Broadcom BCM53xx
 switches
Date: Tue, 24 Feb 2015 14:59:23 -0800
Message-ID: <54ED024B.9090605@gmail.com>
References: <1424799727-30946-1-git-send-email-zajec5@gmail.com>	<54ECFFC3.5070309@gmail.com> <CACna6rxgwdm0YJqf0fTZFROUjC--aiKUNT=tLOF4XwyMrzjtnA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Jonas Gorski <jogo@openwrt.org>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	Felix Fietkau <nbd@openwrt.org>, Jiri Pirko <jiri@resnulli.us>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:45695 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751444AbbBXW7n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 17:59:43 -0500
Received: by pdjz10 with SMTP id z10so119605pdj.12
        for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 14:59:43 -0800 (PST)
In-Reply-To: <CACna6rxgwdm0YJqf0fTZFROUjC--aiKUNT=tLOF4XwyMrzjtnA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/02/15 14:56, Rafa=C5=82 Mi=C5=82ecki wrote:
> On 24 February 2015 at 23:48, Florian Fainelli <f.fainelli@gmail.com>=
 wrote:
>> On 24/02/15 09:42, Rafa=C5=82 Mi=C5=82ecki wrote:
>>> BCM53xx is series of Broadcom Ethernet switches that can be found i=
n
>>> various (mostly home) routers.
>>> They are quite simple switches with mainly just support for:
>>> 1) Tagging incoming packets (PVID)
>>> 2) Untagging outgoing packets
>>> 3) Forwarding all packets across a single VLAN
>>>
>>> This driver is split into common code (module) and bus specific cod=
e.
>>> Right now only PHY (MDIO) support is included, other could follow a=
fter
>>> accepting this driver. It was successfully tested on BCM4706 SoC wi=
th
>>> BCM53125.
>>>
>>> You could notice it's yet another try of submitting b53 driver. Thi=
s
>>> time it was modified to use recently introduced switchdev API which
>>> hopefully make it possible to accept it mainline.
>>
>> This is good as a very basic driver,
>=20
> Thanks :) That was exactly my point: to get a minimal driver (but
> implementing the basic functionality!) accepted and then continue
> improving it.
>=20
>=20
>> there is still a bunch of things
>> missing that might not be too hard to add to this submission:
>>
>> - fetching MIB counters through ethtool
>> - reporting link state/parameters
>> - changing MTU/Jumbo frame support
>> - HW bridging support
>=20
> I agree about missing features. I was already thinking about MIB, it
> should be easy to support it with ethtool_ops and get_sset_count +
> get_strings. Probably the same for link status. Not sure about HW
> bridging.
>=20
> Would you agree to work on having this basic driver accepted first
> (like discussing code location, API usage) and then work on additiona=
l
> features in separated patches? I think it would simplify the process
> and could result in better core review, as people could focus on smal=
l
> bunch of changes.

I would prefer if you could give me the time to implement that:
http://www.spinics.net/lists/netdev/msg295942.html

such that you would get a lot of the network device creation, operation=
s
etc.. for free, with your driver still being a phy_driver ultimately.
But I have no strong objections either.
--=20
=46lorian
