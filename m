From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 00/11] print MAC via printk format specifier
Date: Fri, 24 Feb 2012 14:45:51 +0100
Message-ID: <1330091162-8141-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>, devel@driverdev.osuosl.org,
	e1000-devel@lists.sourceforge.net,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Grant Likely <grant.likely@secretlab.ca>,
	Jiri Kosina <jkosina@suse.cz>, Jiri Pirko <jpirko@redhat.com>,
	linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	Tobias Klauser <tklauser@distanz.ch>
To: "David S. Miller" <davem@davemloft.net>,
	Grant Grundler <grundler@parisc-linux.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Henk de Groot <pe1dnn@amsat.org>,
	Lennert Buytenhek <kernel@wantstofly.org>,
	Marek Belisko <marek.belisko@gmail.com>,
	Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wp188.webpack.hosteurope.de ([80.237.132.195]:43994 "EHLO
	wp188.webpack.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752714Ab2BXNqn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2012 08:46:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Print MAC/dev_addr via printk extended format specifier %pm/%pM
instead of using custom code.

These patches are against net-next.

Danny Kukawka (11):
  arch/ia64/hp/sim/simeth.c: print MAC via printk format specifier
  amd/hplance.c: print MAC via printk format specifier
  cirrus/mac89x0: print MAC via printk format specifier
  dec/tulip/de4x5: print MAC via printk format specifier
  ixgbevf: print MAC via printk format specifier
  sun/sunqe: print MAC via printk format specifier
  xscale/ixp2000/ixpdev: print MAC via printk format specifier
  usb/cdc_ncm: print MAC via printk format specifier
  usb/kaweth: print MAC via printk format specifier
  Staging: ft1000-pcmcia: print MAC via printk format specifier
  Staging: wlags49_h2: print MAC via printk format specifier

 arch/ia64/hp/sim/simeth.c                         |   10 +++-------
 drivers/net/ethernet/amd/hplance.c                |   10 ++--------
 drivers/net/ethernet/cirrus/mac89x0.c             |   12 ++++++++----
 drivers/net/ethernet/dec/tulip/de4x5.c            |    6 +-----
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    8 +-------
 drivers/net/ethernet/sun/sunqe.c                  |   10 ++--------
 drivers/net/ethernet/xscale/ixp2000/ixpdev.c      |    7 ++-----
 drivers/net/usb/cdc_ncm.c                         |    6 +-----
 drivers/net/usb/kaweth.c                          |    8 +-------
 drivers/staging/ft1000/ft1000-pcmcia/ft1000_hw.c  |    7 ++-----
 drivers/staging/wlags49_h2/wl_cs.c                |    7 ++-----
 11 files changed, 25 insertions(+), 66 deletions(-)

-- 
1.7.8.3
