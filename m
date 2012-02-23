From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bug 42809] New: kernel panic when receiving an ipsec packet
Date: Thu, 23 Feb 2012 02:38:03 +0100
Message-ID: <1329961083.15610.2.camel@edumazet-laptop>
References: <bug-42809-100@https.bugzilla.kernel.org/>
	 <20120222092056.5fca788b@nehalam.linuxnetplumber.net>
	 <4F4528CE.7080702@linuxsystems.it> <4F458F82.3060808@linuxsystems.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Linux Networking Developer Mailing List
	<netdev@vger.kernel.org>, openadsl-users@lists.sourceforge.net,
	openadsl-devel@lists.sourceforge.net, support@traverse.com.au,
	support@rocksolidelectronics.com, 660804@bugs.debian.org
To: =?ISO-8859-1?Q?Niccol=F2?= Belli <darkbasic@linuxsystems.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:57114 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752288Ab2BWBiL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2012 20:38:11 -0500
Received: by wics10 with SMTP id s10so428703wic.19
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2012 17:38:10 -0800 (PST)
In-Reply-To: <4F458F82.3060808@linuxsystems.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 23 f=C3=A9vrier 2012 =C3=A0 01:59 +0100, Niccol=C3=B2 Belli a =
=C3=A9crit :
> Hi,
> The bug is still present in latest 3.2.7 vanilla kernel. I wasted the=
=20
> whole day debugging that damn thing and I finally discovered the root=
 cause.
> The problem is with my Traverse Solos multi-port ADSL2+ PCI card[1]=20
> (which has open source drivers included in the kernel) when using RFC=
=20
> 2684 routed.
> I have two adsl lines, the first one connected using RFC 2684 routed,=
=20
> the second one using PPPoA.
> If I create a vpn toward the PPPoA line it works flawlessly, while if=
 I=20
> create a vpn toward the RFC 2684 routed line the whole system hangs i=
n a=20
> kernel panic (with both 2.6.32.54 and 3.2.7).
> I really don't know how to fix it and I need to setup that damn ipsec=
 vpn :(
>=20
> This is the bug on bugzilla.kernel.org:
> https://bugzilla.kernel.org/show_bug.cgi?id=3D42809
>=20
> Niccol=C3=B2
>=20
>=20
> [1]http://www.traverse.com.au/productview.php?product_id=3D116

Which driver handles this Traverse Solos card ?
