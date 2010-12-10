From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] iproute2: ip: add wilcard support for device matching
Date: Fri, 10 Dec 2010 17:32:20 +0100
Message-ID: <1291998740.3580.162.camel@edumazet-laptop>
References: <1291993092-8675-1-git-send-email-opurdila@ixiacom.com>
	 <20101210081846.58b67f09@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Octavian Purdila <opurdila@ixiacom.com>, netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>,
	Vlad Dogaru <ddvlad@rosedu.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:44238 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751573Ab0LJQc0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 11:32:26 -0500
Received: by wwa36 with SMTP id 36so3896565wwa.1
        for <netdev@vger.kernel.org>; Fri, 10 Dec 2010 08:32:24 -0800 (PST)
In-Reply-To: <20101210081846.58b67f09@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 10 d=C3=A9cembre 2010 =C3=A0 08:18 -0800, Stephen Hemminger=
 a =C3=A9crit :
> On Fri, 10 Dec 2010 16:58:12 +0200
> Octavian Purdila <opurdila@ixiacom.com> wrote:
>=20
> > Allow the users to specify a wildcard when selecting a device:
> >=20
> > $ ip set link dev dummy* up
> >=20
> > We do this by expanding the original command line in multiple lines
> > which we then feed via a pipe to a forked ip processed run in batch
> > mode.
> >=20
>=20
>=20
> Seems like feature creep. Can't you do this with bash completion
> script instead.
> -

furthermore, "*" is allowed in a device name

ip link add link bond0 "vlan*" txqueuelen 100 type vlan id 999

$ ifconfig "vlan*"
vlan*     Link encap:Ethernet  HWaddr 00:1E:0B:EC:D3:D2 =20
          BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:100=20
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)



