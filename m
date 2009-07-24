From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Jumbo frame question...
Date: Fri, 24 Jul 2009 21:13:41 +0200
Message-ID: <4A6A07E5.9080705@gmail.com>
References: <200907241141.55097.rgetz@blackfin.uclinux.org> <20090724.093243.201296391.davem@davemloft.net> <4A69E3CF.1040805@hp.com> <200907241421.55986.rgetz@blackfin.uclinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Robin Getz <rgetz@blackfin.uclinux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:37891 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753900AbZGXTPI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2009 15:15:08 -0400
In-Reply-To: <200907241421.55986.rgetz@blackfin.uclinux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robin Getz a =C3=A9crit :
> On Fri 24 Jul 2009 12:39, Rick Jones pondered:
>> David Miller wrote:
>>> From: Robin Getz <rgetz@blackfin.uclinux.org>
>>> Date: Fri, 24 Jul 2009 11:41:55 -0400
>>>
>>>> Should a gigabit card, configured as 100, be sending jumbo UDP fra=
mes?
>>>>
>>>> My understanding, is no - this is a spec violation..
>> In so far as there is no de jure spec for Jumbo Frames, it is rather
>> difficult to have a spec violation :).
>=20
> The spec I was talking about was the MTU...
>=20
> rgetz@pinky:~> /sbin/ifconfig eth0
> eth0      Link encap:Ethernet  HWaddr 00:11:11:B0:A5:D4
>           inet addr:192.168.0.10  Bcast:192.168.0.255  Mask:255.255.2=
55.0
>           inet6 addr: fe80::211:11ff:feb0:a5d4/64 Scope:Link
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:45978 errors:5 dropped:0 overruns:0 frame:0
>           TX packets:44536 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:3193 txqueuelen:1000
>           RX bytes:11583575 (11.0 Mb)  TX bytes:20025122 (19.0 Mb)
>           Interrupt:16
>=20
>=20
> My MTU is 1500, but when tftp requests a block size of over that - th=
e host=20
> does not fragment it (like I thought it should).

Which broken driver would do this me asking, and how can you be sure a =
jumbo frame was ever sent ?

I guess your tcpdump is fooled by gso settings... Did you tried
# ethtool -K eth0 gso off=20



