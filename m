From: Pavel Machek <pavel@ucw.cz>
Subject: Extremely bad performance with RTL8111/8168B
Date: Mon, 8 Jul 2013 11:54:59 +0200
Message-ID: <20130708095459.GA29788@amd.pavel.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: nic_swsd@realtek.com, romieu@fr.zoreil.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:58232 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751203Ab3GHJzC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jul 2013 05:55:02 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

I've small Intel desktop with RTL8111/8168B ethernet... but the
performance is extremely bad.

In 3.10, I only get about 200KB/sec:

pavel@amd:~$ scp /tmp/delme pavel@duo:/tmp
pavel@duo's password: 
delme                                               100%   16MB
236.0KB/s   01:09    

In older version, I get 1MB/s, but network fails every 10 minutes or
so. Card is:

03:00.0 Ethernet controller: Realtek Semiconductor Co.,
Ltd. RTL8111/8168B PCI Express Gigabit Ethernet controller (rev 03)

I did install firmware-realtek package as suggested by debian
installer.

Dmesg says:

r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
r8169 0000:03:00.0 eth0: RTL8168d/8111d at 0xf8010000,
00:27:0e:2a:43:71, XID 081000c0 IRQ 17
r8169 0000:03:00.0 eth0: jumbo features [frames: 9200 bytes, tx
checksumming: ko]

Any ideas what is wrong?

Thanks,
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
