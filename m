From: Jeff Garzik <jgarzik@pobox.com>
Subject: [BK PATCHES] net driver merges
Date: Mon, 23 Jun 2003 22:32:11 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030624023211.GA2592@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: torvalds@transmeta.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Linus, please do a

	bk pull bk://kernel.bkbits.net/jgarzik/net-drivers-2.5

Others may download the patch from

ftp://ftp.kernel.org/pub/linux/kernel/people/jgarzik/patchkits/2.5/2.5.73-bk1-netdrvr1.patch.bz2

This will update the following files:

 drivers/net/sk98lin/skge.c   |  598 +++++++++++++++++++++----------------------
 drivers/net/wan/sdla_chdlc.c |    4 
 drivers/net/wan/sdla_fr.c    |    4 
 drivers/net/wan/sdla_ppp.c   |    4 
 drivers/net/wan/sdla_x25.c   |    4 
 5 files changed, 297 insertions(+), 317 deletions(-)

through these ChangeSets:

<romieu@fr.zoreil.com> (03/06/23 1.1413)
   [netdrvr sk98lin] PCI API conversion, and some cleanups
   
   
   - PCI API init style conversion for drivers/net/sk98lin/skge.c;
   - new helpers: SkGeDev{Init/CleanUp};
   - sk_devs_lock moved around as it's needed early.
   
   Compiles without error. Untested.

<rusty@rustcorp.com.au> (03/06/23 1.1412)
   [PATCH] [PATCH 2.5.72] Use mod_timer in drivers_net_wan_sdla_chdlc.c
   
   From:  Vinay K Nallamothu <vinay-rc@naturesoft.net>

<rusty@rustcorp.com.au> (03/06/23 1.1411)
   [PATCH] [PATCH 2.5.72] Use mod_timer in drivers_net_wan_sdla_x25.c
   
   From:  Vinay K Nallamothu <vinay-rc@naturesoft.net>

<rusty@rustcorp.com.au> (03/06/23 1.1410)
   [PATCH] [PATCH 2.5.72] Use mod_timer in drivers_net_wan_sdla_ppp.c
   
   From:  Vinay K Nallamothu <vinay-rc@naturesoft.net>

<rusty@rustcorp.com.au> (03/06/23 1.1409)
   [PATCH] {PATCH 2.5.72] Use mod_timer in drivers_net_wan_sdla_fr.c
   
   From:  Vinay K Nallamothu <vinay-rc@naturesoft.net>
