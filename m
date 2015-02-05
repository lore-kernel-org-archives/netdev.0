From: Pavel Machek <pavel@ucw.cz>
Subject: Ethernet: how to disable gigabit support
Date: Thu, 5 Feb 2015 21:25:27 +0100
Message-ID: <20150205202527.GA7917@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: kernel list <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

This happened on more than one project: there's gigabit-capable chip,
but the connector is not designed for gigabit speed.

I'd like to have speed autonegotiation, but not offer gigabit (as it
will not work).

Is there way to do that without hacking the kernel? Should mii-tool do
that?

Thanks,
								Pavel

root@ib8315:~# mii-tool.net-tools  -A 100baseTx,10baseT eth1
restarting autonegotiation...
root@ib8315:~# [32432.443883] libphy: mdio@e0024520:01 - Link is Down

root@ib8315:~# [32435.447863] libphy: mdio@e0024520:01 - Link is Up - 1000/Full

root@ib8315:~# mii-tool.net-tools -v eth1
eth1: negotiated 1000baseT-FD flow-control, link ok
product info: vendor 00:01:c1, model 3 rev 1
basic mode:   autonegotiation enabled
 basic status: autonegotiation complete, link ok
 capabilities: 1000baseT-FD 100baseTx-FD 100baseTx-HD
 10baseT-FD 10baseT-HD
 advertising:  1000baseT-FD 100baseTx-FD 100baseTx-HD
 10baseT-FD 10baseT-HD
 link partner: 1000baseT-FD 100baseTx-FD 100baseTx-HD
 10baseT-FD 10baseT-HD flow-control
 root@ib8315:~# mii-tool.net-tools -V
 $Id: mii-tool.c,v 1.9 2006/09/27 20:59:18 ecki Exp $
 (Author: David Hinds based on Donald Becker's mii-diag)
 net-tools 1.60
 root@ib8315:~#
	    
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
