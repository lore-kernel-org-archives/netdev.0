From: =?ISO-8859-1?Q?N=E9meth_M=E1rton?= <nm127@freemail.hu>
Subject: Re: [Bugme-new] [Bug 14794] New: IP address assigned by DHCP is
  dropped after ~40 seconds
Date: Fri, 18 Dec 2009 17:49:01 +0100
Message-ID: <4B2BB27D.5050609@freemail.hu>
References: <bug-14794-10286@http.bugzilla.kernel.org/>	<20091216154713.f082e7cf.akpm@linux-foundation.org>	<4B2A9A40.90203@freemail.hu> <20091217132451.b168a796.akpm@linux-foundation.org> <4B2AA64C.50709@gmail.com> <4B2B35B7.6060703@freemail.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Mike Galbraith <efault@gmx.de>, Ingo Molnar <mingo@elte.hu>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail01d.mail.t-online.hu ([84.2.42.6]:61749 "EHLO
	mail01d.mail.t-online.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750771AbZLRQtJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 11:49:09 -0500
In-Reply-To: <4B2B35B7.6060703@freemail.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

N=E9meth M=E1rton worte:
> I use KDE, and the KNetworkManager icon is visible on the task bar. W=
hen
> I unplug the network cable the "disconnected" icon appears. After I p=
lug the
> network cable again, a rotating wheel appears. Here comes the differe=
nce: *when*
> the rotating wheel changes to "connected" state. One case, when the I=
P address
> is kept the "connected" icon appears right after the IP address assig=
ned by
> DHCP appears in the ifconfig output. In the wrong case this rotating =
wheel is
> still there for about 60 seconds while the the assigned IP address is=
 dropped
> and an IP address like 169.254.123.251 is assigned.

I would like to add that with 2.6.32 the IP address is dropped even if =
I exit
the KNetworkManager before unplugging the network cable.

I can reproduce the problem without touching the network cable. If I ex=
ecute
(I am running Debian 5.0, kernel 2.6.32):

# /etc/init.d/network-manager stop

then the network goes down. After this I execute:

# /etc/init.d/network-manager start

then the network comes up, the IP address assigned by DHCP appears for =
about a
minute then the this IP address is dropped and the address starting wit=
h
169.254 is assigned.

Regards,

	M=E1rton N=E9meth
