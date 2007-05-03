From: "Robert P. J. Day" <rpjday@mindspring.com>
Subject: finding your own dead "CONFIG_" variables
Date: Thu, 3 May 2007 04:19:48 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0705030400120.20539@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nic.NetDirect.CA ([216.16.235.2]:47075 "EHLO
	rubicon.netdirect.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750888AbXECIUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 04:20:09 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


  while there's still a pile of possible dead CONFIG_ variables under
the fs/ and drivers/ directories i haven't posted yet, you don't need
to wait for me to generate them.  take a minute and run the script
yourself:

http://fsdev.net/wiki/index.php?title=Dead_CONFIG_variables

  a couple of examples:

$ ../dead_config.sh net/wanrouter
========== WANPIPE_MULTPPP ==========
net/wanrouter/wanmain.c:#ifdef CONFIG_WANPIPE_MULTPPP
net/wanrouter/wanmain.c:#ifdef CONFIG_WANPIPE_MULTPPP
net/wanrouter/wanmain.c:#ifdef CONFIG_WANPIPE_MULTPPP

$ ../dead_config.sh drivers/net/wireless
========== BCM947XX ==========
drivers/net/wireless/bcm43xx/bcm43xx_dma.c:663:#ifdef CONFIG_BCM947XX
drivers/net/wireless/bcm43xx/bcm43xx_main.h:36:#ifdef CONFIG_BCM947XX
drivers/net/wireless/bcm43xx/bcm43xx_main.c:64:#ifdef CONFIG_BCM947XX
drivers/net/wireless/bcm43xx/bcm43xx_main.c:145:#ifdef CONFIG_BCM947XX
drivers/net/wireless/bcm43xx/bcm43xx_main.c:789:#ifdef CONFIG_BCM947XX
drivers/net/wireless/bcm43xx/bcm43xx_main.c:799:#ifdef CONFIG_BCM947XX
drivers/net/wireless/bcm43xx/bcm43xx_main.c:1228:#ifdef CONFIG_BCM947XX
drivers/net/wireless/bcm43xx/bcm43xx_main.c:1390://FIXME: Do we _really_ want #ifndef CONFIG_BCM947XX here?
drivers/net/wireless/bcm43xx/bcm43xx_main.c:1392:#ifndef CONFIG_BCM947XX
drivers/net/wireless/bcm43xx/bcm43xx_main.c:2143:#ifdef CONFIG_BCM947XX
drivers/net/wireless/bcm43xx/bcm43xx_main.c:2155:#ifdef CONFIG_BCM947XX
drivers/net/wireless/bcm43xx/bcm43xx_main.c:2648:#ifdef CONFIG_BCM947XX
drivers/net/wireless/bcm43xx/bcm43xx_main.c:4147:#ifdef CONFIG_BCM947XX
drivers/net/wireless/bcm43xx/bcm43xx.h:661:#ifdef CONFIG_BCM947XX
drivers/net/wireless/bcm43xx/bcm43xx.h:792:#ifdef CONFIG_BCM947XX
$

  go wild.

rday
-- 
========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://fsdev.net/wiki/index.php?title=Main_Page
========================================================================
