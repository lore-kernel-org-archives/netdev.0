From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] iproute2: ip: add wilcard support for device matching
Date: Fri, 10 Dec 2010 18:42:39 +0100
Message-ID: <1292002959.3580.321.camel@edumazet-laptop>
References: <1291993092-8675-1-git-send-email-opurdila@ixiacom.com>
	 <20101210081846.58b67f09@nehalam>
	 <1291998740.3580.162.camel@edumazet-laptop>
	 <201012101932.59352.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>,
	Vlad Dogaru <ddvlad@rosedu.org>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:51369 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753991Ab0LJRmu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 12:42:50 -0500
Received: by wwa36 with SMTP id 36so3971403wwa.1
        for <netdev@vger.kernel.org>; Fri, 10 Dec 2010 09:42:49 -0800 (PST)
In-Reply-To: <201012101932.59352.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 10 d=C3=A9cembre 2010 =C3=A0 19:32 +0200, Octavian Purdila =
a =C3=A9crit :

> Would allowing escaping it fix the issue? Like:
>=20
> ip link add link bond0 "vlan\*" txqueuelen 100 type vlan id 999
>=20

Well, same compat problem ;)

$ ip link add link bond0 "vlan\*199" type vlan id 199
$ ifconfig "vlan\*199"
vlan\199  Link encap:Ethernet  HWaddr 00:1E:0B:EC:D3:D2 =20
          BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0=20
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)




