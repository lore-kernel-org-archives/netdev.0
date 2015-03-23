From: Wolfgang Rosner <wrosner@tirnet.de>
Subject: Re: One way TCP bottleneck over 6 x Gbit tecl aggregated link // Kernel issue
Date: Mon, 23 Mar 2015 01:57:44 +0100
Message-ID: <201503230157.46489.wrosner@tirnet.de>
References: <201503210110.48980.wrosner@tirnet.de> <1427043294.25985.52.camel@edumazet-glaptop2.roam.corp.google.com> <201503222148.00332.wrosner@tirnet.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tirnet.de ([217.7.138.221]:20661 "EHLO mail.tirnet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751880AbbCWA5u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Mar 2015 20:57:50 -0400
In-Reply-To: <201503222148.00332.wrosner@tirnet.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Eric,

It's the kernel, stupid me....

I can't belive it:

I just bootet my gatway into a debian kernel, and it works right away:
	5.93 Gbits/sec	over a single TCP connection :-)))

root@cruncher:~# cat /proc/version
Linux version 3.16.0-0.bpo.4-amd64 (debian-kernel@lists.debian.org) (gcc 
version 4.6.3 (Debian 4.6.3-14) ) #1 SMP Debian 3.16.7-ckt4-3~bpo70+1 
(2015-02-12)

as opposed to vanilla 3.19, which was running in the previous tests.

=====================
the sad thing is, that I had to remove the "udba=notify" option from my 
aufs-layered nfsroots mimics.
So anytime I make config-Changes or add packages to the blade setup, I have to 
run a script to remount all nfs roots, to get the blade known of the change.
(this was the reason why I went for 3.19)
======================


Therefore, I would be glad to get it working with 3.19, too.
And I hope that you, too, were eager to rule out the possibility of a 
regression bug :-)


So, what could had have happend:
- regression bug somewhere in the kernel
- broken compatibility between 3.16 and 3.19 (maybe the iproute2 tools?)
- broken compatibility between Vanilla and Debian
- ????

Are you ready to assist me on this track?



Wolfgang Rosner
