From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Huge performance degradation for UDP between 2.4.17 and 2.6
Date: Sun, 05 Aug 2012 10:28:51 +0200
Message-ID: <1344155331.9299.1573.camel@edumazet-glaptop>
References: <501A722D.1070900@c-s.fr>
	 <1343916836.9299.189.camel@edumazet-glaptop>  <501E2BC5.5020709@c-s.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: LEROY christophe <christophe.leroy@c-s.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:43103 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752893Ab2HEI25 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Aug 2012 04:28:57 -0400
In-Reply-To: <501E2BC5.5020709@c-s.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-08-05 at 10:16 +0200, LEROY christophe wrote:
> Le 02/08/2012 16:13, Eric Dumazet a =C3=A9crit :
> > On Thu, 2012-08-02 at 14:27 +0200, leroy christophe wrote:
> >> Hi
> >>
> >> I'm having a big issue with UDP. Using a powerpc board (MPC860).
> >>
> >> With our board running kernel 2.4.17, I'm able to send 160000 voic=
e
> >> packets (UDP, 96 bytes per packet) in 11 seconds.
> >> With the same board running either Kernel 2.6.35.14 or Kernel 3.4.=
7, I
> >> need 55 seconds to send the same amount of packets.
> >>
> >>
> >> Is there anything to tune in order to get same output rate as with
> >> Kernel 2.4 ?
> > kernel size is probably too big for your old / slow cpu.
> >
> > Maybe you added too many features on your 3.4.7 kernel. (netfilter =
?
> > SLUB debugging ...)
> >
> > Its hard to say, 2.4.17 had less features and was faster.
> >
>=20
> Thanks for your answer.
> Yes I have netfilter as I need it. However, I tried without it and st=
ill=20
> need about 37 seconds to send the 160000 packets I was sending in 11=20
> seconds with 2.4.17
>=20
> I don't think there is any problem with size of the kernel. I still h=
ave=20
> plenty of memory available.
>=20

I believe you misunderstood me.

I was referring to cpu caches ( dcache & icache )

> All debugging is turned off, and I'm not using SLUB but SLOB.
> I have 32Mbytes of RAM. Would SLUB be more performant than SLOB ?

I never used SLOB I cannot comment

Please provide (on 3.4.7)

cat /proc/cpuinfo
lsmod
dmesg
