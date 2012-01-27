From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch v4, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet
 multipoint GRE over IP
Date: Fri, 27 Jan 2012 06:59:44 +0100
Message-ID: <1327643984.2919.6.camel@edumazet-laptop>
References: <CAGsizzJnRy74ni-HH=5q1VR4g6sfDPg9SFw4UKgSjJjkSR8OJA@mail.gmail.com>
	 <20120125.203746.1977019610549185259.davem@davemloft.net>
	 <CAGsizzLYxsc2MGxF7yK_QzS+3bexHa1F_6+NE87u3F18m7=R1g@mail.gmail.com>
	 <20120126.133033.964571202129052712.davem@davemloft.net>
	 <CAOzFzEj-UCXwhw0NA=Y=qExG=RdVJB3RAdqU0HrsMo7V+4eGcQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, steweg@ynet.sk,
	jesse@nicira.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joseph Glanville <joseph.glanville@orionvm.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:58166 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752313Ab2A0F7t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 00:59:49 -0500
In-Reply-To: <CAOzFzEj-UCXwhw0NA=Y=qExG=RdVJB3RAdqU0HrsMo7V+4eGcQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 27 janvier 2012 =C3=A0 09:24 +1100, Joseph Glanville a =C3=A9=
crit :
> David is correct, the forwarding speed of Open vSwitch is at parity
> with the Linux Bridging module and its tunneling speed is actually
> slightly faster than the in kernel GRE implementation. I have tested
> this across a variety of configurations.

Thanks for this input ! When was this tested exactly, and do you have
some "perf tool" reports to provide ?

GRE is lockless since one year or so (modulo how is setup the tunnel as
discovered recently)

Also please note that openvSwitch is said to be fast path only on
established flows.
