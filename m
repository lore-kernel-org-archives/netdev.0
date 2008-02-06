From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: sk98lin driver removal for 2.6.25
Date: Wed, 6 Feb 2008 13:52:33 -0800
Message-ID: <20080206135233.58c1ba9d@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:55845 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757969AbYBFV6v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 16:58:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch is too large for mailing list so please pull from:

  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/sk98lin master

Stephen Hemminger (1):
      sk98lin: remove obsolete driver

 Documentation/feature-removal-schedule.txt |   10 -
 drivers/net/Kconfig                        |   87 -
 drivers/net/Makefile                       |    1 -
 drivers/net/sk98lin/Makefile               |   87 -
 drivers/net/sk98lin/h/lm80.h               |  179 -
 drivers/net/sk98lin/h/skaddr.h             |  285 -
 drivers/net/sk98lin/h/skcsum.h             |  213 -
 drivers/net/sk98lin/h/skdebug.h            |   74 -
 drivers/net/sk98lin/h/skdrv1st.h           |  188 -
 drivers/net/sk98lin/h/skdrv2nd.h           |  447 --
 drivers/net/sk98lin/h/skerror.h            |   55 -
 drivers/net/sk98lin/h/skgedrv.h            |   51 -
 drivers/net/sk98lin/h/skgehw.h             | 2126 -------
 drivers/net/sk98lin/h/skgehwt.h            |   48 -
 drivers/net/sk98lin/h/skgei2c.h            |  210 -
 drivers/net/sk98lin/h/skgeinit.h           |  797 ---
 drivers/net/sk98lin/h/skgepnm2.h           |  334 --
 drivers/net/sk98lin/h/skgepnmi.h           |  962 ----
 drivers/net/sk98lin/h/skgesirq.h           |  110 -
 drivers/net/sk98lin/h/ski2c.h              |  174 -
 drivers/net/sk98lin/h/skqueue.h            |   94 -
 drivers/net/sk98lin/h/skrlmt.h             |  438 --
 drivers/net/sk98lin/h/sktimer.h            |   63 -
 drivers/net/sk98lin/h/sktypes.h            |   69 -
 drivers/net/sk98lin/h/skversion.h          |   38 -
 drivers/net/sk98lin/h/skvpd.h              |  248 -
 drivers/net/sk98lin/h/xmac_ii.h            | 1579 ------
 drivers/net/sk98lin/skaddr.c               | 1788 ------
 drivers/net/sk98lin/skdim.c                |  742 ---
 drivers/net/sk98lin/skethtool.c            |  627 ---
 drivers/net/sk98lin/skge.c                 | 5218 ------------------
 drivers/net/sk98lin/skgehwt.c              |  171 -
 drivers/net/sk98lin/skgeinit.c             | 2005 -------
 drivers/net/sk98lin/skgemib.c              | 1075 ----
 drivers/net/sk98lin/skgepnmi.c             | 8198 ----------------------------
 drivers/net/sk98lin/skgesirq.c             | 2229 --------
 drivers/net/sk98lin/ski2c.c                | 1296 -----
 drivers/net/sk98lin/sklm80.c               |  141 -
 drivers/net/sk98lin/skqueue.c              |  179 -
 drivers/net/sk98lin/skrlmt.c               | 3257 -----------
 drivers/net/sk98lin/sktimer.c              |  250 -
 drivers/net/sk98lin/skvpd.c                | 1091 ----
 drivers/net/sk98lin/skxmac2.c              | 4160 --------------
 43 files changed, 0 insertions(+), 41394 deletions(-)
 delete mode 100644 drivers/net/sk98lin/Makefile
 delete mode 100644 drivers/net/sk98lin/h/lm80.h
 delete mode 100644 drivers/net/sk98lin/h/skaddr.h
 delete mode 100644 drivers/net/sk98lin/h/skcsum.h
 delete mode 100644 drivers/net/sk98lin/h/skdebug.h
 delete mode 100644 drivers/net/sk98lin/h/skdrv1st.h
 delete mode 100644 drivers/net/sk98lin/h/skdrv2nd.h
 delete mode 100644 drivers/net/sk98lin/h/skerror.h
 delete mode 100644 drivers/net/sk98lin/h/skgedrv.h
 delete mode 100644 drivers/net/sk98lin/h/skgehw.h
 delete mode 100644 drivers/net/sk98lin/h/skgehwt.h
 delete mode 100644 drivers/net/sk98lin/h/skgei2c.h
 delete mode 100644 drivers/net/sk98lin/h/skgeinit.h
 delete mode 100644 drivers/net/sk98lin/h/skgepnm2.h
 delete mode 100644 drivers/net/sk98lin/h/skgepnmi.h
 delete mode 100644 drivers/net/sk98lin/h/skgesirq.h
 delete mode 100644 drivers/net/sk98lin/h/ski2c.h
 delete mode 100644 drivers/net/sk98lin/h/skqueue.h
 delete mode 100644 drivers/net/sk98lin/h/skrlmt.h
 delete mode 100644 drivers/net/sk98lin/h/sktimer.h
 delete mode 100644 drivers/net/sk98lin/h/sktypes.h
 delete mode 100644 drivers/net/sk98lin/h/skversion.h
 delete mode 100644 drivers/net/sk98lin/h/skvpd.h
 delete mode 100644 drivers/net/sk98lin/h/xmac_ii.h
 delete mode 100644 drivers/net/sk98lin/skaddr.c
 delete mode 100644 drivers/net/sk98lin/skdim.c
 delete mode 100644 drivers/net/sk98lin/skethtool.c
 delete mode 100644 drivers/net/sk98lin/skge.c
 delete mode 100644 drivers/net/sk98lin/skgehwt.c
 delete mode 100644 drivers/net/sk98lin/skgeinit.c
 delete mode 100644 drivers/net/sk98lin/skgemib.c
 delete mode 100644 drivers/net/sk98lin/skgepnmi.c
 delete mode 100644 drivers/net/sk98lin/skgesirq.c
 delete mode 100644 drivers/net/sk98lin/ski2c.c
 delete mode 100644 drivers/net/sk98lin/sklm80.c
 delete mode 100644 drivers/net/sk98lin/skqueue.c
 delete mode 100644 drivers/net/sk98lin/skrlmt.c
 delete mode 100644 drivers/net/sk98lin/sktimer.c
 delete mode 100644 drivers/net/sk98lin/skvpd.c
 delete mode 100644 drivers/net/sk98lin/skxmac2.c
