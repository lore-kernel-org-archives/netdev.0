From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 33842] New: NULL pointer dereference in
 ip_fragment
Date: Wed, 27 Apr 2011 09:41:07 +0200
Message-ID: <1303890067.3166.4.camel@edumazet-laptop>
References: <20110426203154.GM15903@stratus.com>
	 <20110426.134637.48491363.davem@davemloft.net>
	 <1303851185.2699.7.camel@edumazet-laptop>
	 <20110426205901.GN15903@stratus.com>
	 <1303851718.2699.8.camel@edumazet-laptop>
	 <20110426211946.GO15903@stratus.com>
	 <1303853047.2699.15.camel@edumazet-laptop>  <4DB7C44D.60306@dbservice.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Bandan Das <bandan.das@stratus.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: Tomas Carnecky <tom@dbservice.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:44283 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752936Ab1D0HlO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 03:41:14 -0400
Received: by wya21 with SMTP id 21so1029873wya.19
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2011 00:41:13 -0700 (PDT)
In-Reply-To: <4DB7C44D.60306@dbservice.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 27 avril 2011 =C3=A0 09:22 +0200, Tomas Carnecky a =C3=A9cr=
it :
> On 4/26/11 11:24 PM, Eric Dumazet wrote:
> > Le mardi 26 avril 2011 =C3=A0 17:19 -0400, Bandan Das a =C3=A9crit =
:
> >> Yeah, I just rechecked and this is already in Linus' tree. So, Tom=
as you can
> >> either try pulling in those changes or you can apply this patch an=
d see
> >> if it makes any difference. Thanks!
> > Better pull Linus tree because there is another patch involved.
> >
> > (commits c65353daf137dd41f3ede3baf62d561fca076228
> > ip: ip_options_compile() resilient to NULL skb route
>=20
> Still getting that error (on rc4-00245-g4175242, which includes that=20
> commit).
>=20

Could you send us a complete trace ?

One way to get one is to use netconsole (provided you have another
machine )

grep NETCONSOLE .config
CONFIG_NETCONSOLE=3Dy

Add on your boot command

netconsole=3D4444@192.168.20.108/eth0,4444@192.168.20.112/00:1e:0b:ec:c=
3:e4

messages sent to host 192.168.20.112 udp port 4444, mac addr 00:1e:0b:e=
c:c3:e4, on eth0

then on 192.168.20.112 start a netcat listening on udp port 4444 to get
a copy of messages.

netcat -l -u -p 4444

Complete doc on Documentation/networking/netconsole.txt

Thanks !


