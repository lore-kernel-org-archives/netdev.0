From: Pavel Machek <pavel@denx.de>
Subject: socfpga/sockit ethernet problems
Date: Wed, 7 May 2014 12:45:18 +0200
Message-ID: <20140507104518.GB18139@amd.pavel.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	dinguyen@altera.com, linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:57376 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755389AbaEGKpU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 06:45:20 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

It seems we have some problems with Ethernet on socfpga boards.

Like, "stmmac: Energy-Efficient Ethernet initialized" repeated way too
often. Or machine failing to boot because NFS server can not be
accessed. (And then working on next try). Or link going up and down
and up and down. Or link taking 3 seconds, 10 seconds to estabilish.

It also seems to be picky about hubs it wants to talk to.

This time it mounted root; on last boot it just hung.

Mounts root 31.394855 Waiting 5 sec before mounting root device...
Mounts root 33.331379 stmmaceth ff702000.ethernet eth0: Link is Up -
100Mbps/Full - flow control rx/tx
Mounts root 36.418308 VFS: Mounted root (nfs filesystem) on device
0:12.
### Milestone reached:  Mounts root
Userland boots 51.455751 nfs: server 192.168.1.1 not responding, still
trying
Userland boots 52.552075 nfs: server 192.168.1.1 OK
Userland boots 52.555110 devtmpfs: mounted
Userland boots 52.566032 Freeing unused kernel memory: 264K (80597000
- 805d9000)
Userland boots 61.395175 nfs: server 192.168.1.1 not responding, still
trying
Userland boots 61.401301 nfs: server 192.168.1.1 OK

U-boot seems to configure phy timing:

u-boot talk 12.033741 Configuring PHY skew timing for Micrel ksz9021

is there something similar that needs to be done at Linux layer.

Any ideas? Thanks,
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
