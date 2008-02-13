From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: 64bit counters: iproute(netlink) vs ifconfig
Date: Wed, 13 Feb 2008 12:35:09 -0800
Message-ID: <20080213123509.7bff7b7b@extreme>
References: <Pine.LNX.4.64.0802132114110.16999@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:34111 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753335AbYBMUfX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 15:35:23 -0500
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1JPOK5-0001n1-1P
	for netdev@vger.kernel.org; Wed, 13 Feb 2008 20:35:17 +0000
Received: from 75-175-36-245.ptld.qwest.net ([75.175.36.245])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 13 Feb 2008 20:35:17 +0000
Received: from shemminger by 75-175-36-245.ptld.qwest.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 13 Feb 2008 20:35:17 +0000
In-Reply-To: <Pine.LNX.4.64.0802132114110.16999@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 Feb 2008 21:20:59 +0100 (CET)
Krzysztof Oledzki <olel@ans.pl> wrote:

> Hello,
>=20
> Just discovered that counters returned by the "ip" tool are truncated=
:
>=20
> # ip -s link show bond0
> 1: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc noq=
ueue
>      link/ether 00:1d:09:67:6e:2f brd ff:ff:ff:ff:ff:ff
>      RX: bytes  packets  errors  dropped overrun mcast
>      2485605521 9010211  0       0       0       6
>      TX: bytes  packets  errors  dropped carrier collsns
>      3023237974 9345397  0       0       0       0
>=20
> # ifconfig bond0
> bond0     Link encap:Ethernet  HWaddr 00:1D:09:67:6E:2F
>            inet addr:192.168.152.62  Bcast:192.168.152.255  Mask:255.=
255.255.0
>            inet6 addr: fe80::21d:9ff:fe67:6e2f/64 Scope:Link
>            UP BROADCAST RUNNING MASTER MULTICAST  MTU:1500  Metric:1
>            RX packets:9010367 errors:0 dropped:351 overruns:0 frame:0
>            TX packets:9345521 errors:0 dropped:0 overruns:0 carrier:0
>            collisions:0 txqueuelen:0
>            RX bytes:2485631020 (2370.4 Mb)  TX bytes:7318232294 (6979=
=2E2 Mb)
>=20
> Is it possible to get 64-bit counters in ip via netlink? Struct=20
> rtnl_link_stats does not look very optimistic, as it has rx_bytes/tx_=
bytes=20
> defined with __u32.
>=20
> Best regards,
>=20
>  				Krzysztof Ol=C4=99dzki

The problem is the kernel binary API is now hard coded to 32 bit values=
=2E

--=20
Stephen Hemminger <stephen.hemminger@vyatta.com>


