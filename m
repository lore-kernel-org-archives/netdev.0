From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 33842] New: NULL pointer dereference in
 ip_fragment
Date: Wed, 27 Apr 2011 14:17:36 +0200
Message-ID: <1303906656.3166.48.camel@edumazet-laptop>
References: <20110426203154.GM15903@stratus.com>
	 <20110426.134637.48491363.davem@davemloft.net>
	 <1303851185.2699.7.camel@edumazet-laptop>
	 <20110426205901.GN15903@stratus.com>
	 <1303851718.2699.8.camel@edumazet-laptop>
	 <20110426211946.GO15903@stratus.com>
	 <1303853047.2699.15.camel@edumazet-laptop>  <4DB7C44D.60306@dbservice.com>
	 <1303890067.3166.4.camel@edumazet-laptop>  <4DB8037E.7010207@dbservice.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Bandan Das <bandan.das@stratus.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: Tomas Carnecky <tom@dbservice.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:45303 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932247Ab1D0MRl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 08:17:41 -0400
Received: by wwa36 with SMTP id 36so1813708wwa.1
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2011 05:17:40 -0700 (PDT)
In-Reply-To: <4DB8037E.7010207@dbservice.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 27 avril 2011 =C3=A0 13:52 +0200, Tomas Carnecky a =C3=A9cr=
it :
> On 4/27/11 9:41 AM, Eric Dumazet wrote:
> > netconsole=3D4444@192.168.20.108/eth0,4444@192.168.20.112/00:1e:0b:=
ec:c3:e4
> I'm not having any luck with the netconsole. The last message I see o=
n=20
> the target host is "Freeing unused kernel memory: 100k freed". I don'=
t=20
> see any messages after that. Do I need to configure the same IP addre=
ss=20
> in netconsole as is later configured by userspace? I set netconsole t=
o=20
> use 192.168.0.50 while the init scripts set br0 to have 192.168.0.82.=
=20
> And would netconsole even work, as the bug is in the networking code =
itself?
>=20
>=20

It should work yes, even for a bug in networking stack.

Yes, you should take the source address you're supposed to have once
machine running. I suspect it could work with another IP address, but
using the normal one makes sure you dont hit some anti spoofing rule in
your LAN.

To check if netconsole works (after boot), you can try

dmesg -n 8
modprobe pktgen

You should see on remote machine :
pktgen: Packet Generator for packet performance testing. Version: 2.74



