From: Vincent ETIENNE <ve@vetienne.net>
Subject: Re: [PROBLEM] Bonding driver in linux-2.6.21-rc6-mm1
Date: Sun, 29 Apr 2007 00:04:31 +0200
Message-ID: <200704290004.31698.ve@vetienne.net>
References: <200704262058.33087.ve@vetienne.net> <200704282237.42753.ve@vetienne.net> <20070428143102.f39299b5.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.vetienne.net ([87.98.219.23]:2262 "EHLO
	mail1.vetienne.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1160997AbXD1WEd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2007 18:04:33 -0400
In-Reply-To: <20070428143102.f39299b5.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le Saturday 28 April 2007 23:31:02 Andrew Morton, vous avez =E9crit=A0:
>
> > Is there anything i can do to get you more precise information ?
>
> I guess if you could provide us with your .config and a step-by-step =
recipe
> which developers should use to reproduce the problem then we should b=
e able
> to fix this pretty easily when someone finds the time to do so.

=46or the config, i have uploaded it to=20
http://mail1.vetienne.net/linux/config-2.6.21-rc7-mm2.=20

=46or reproducing the problem, it 's simple (for me at least) :

	-  setup a bonding interface ( IP 192.168.1.5/255.255.255.0 so nothing=
=20
fancy ) bond (mode 6 : alb ) on two NIC card (in my case  E1000 and TG3=
 ).=20
Don't know if it's important or not but the two cards are connected to =
the=20
same cheap 100Mb switch ( So no gigabit )

	- Reboot  : when the bond interface went up ( after the two physical s=
laves )=20
the bug is triggered ( for the moment always, but i have only rebooted =
2 or 3=20
times with 2.6.21-rc7-mm2  ).

	- You could also play with networks cable and put down/up one interfac=
e or=20
another  during normal work : it would often triggered the same trace (=
 not=20
always although ). You don't need to have load on the network. The inte=
rface=20
that went down or up doesn't seem to be important as far as i can see.

	- No lockup of the kernel, network still work fine after the problem







