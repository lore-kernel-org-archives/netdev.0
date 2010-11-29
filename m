From: Joe Perches <joe@perches.com>
Subject: [PATCH 00/11] forcedeth: Convert to use netdev_<level> and neatening
Date: Mon, 29 Nov 2010 09:41:51 -0800
Message-ID: <cover.1291051316.git.joe@perches.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Szymon Janc <szymon@janc.net.pl>,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirqus@gmail.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some mild restructuring and some generally neatening.

The conversions of dprintk to netdev_dbg in patches 2 and 4 are
deleted in patch 10 as these seem to have been used only
during initial development and are not normally compiled-in.

Patch 10 may be ignored if desired.

Object size is reduced ~2Kb overall.

$ size drivers/net/forcedeth.o.*
   text	   data	    bss	    dec	    hex	filename
  71739	    336	  17176	  89251	  15ca3	drivers/net/forcedeth.o.new
  73416	    240	  17696	  91352	  164d8	drivers/net/forcedeth.o.old

Joe Perches (11):
  forcedeth: Change reg_delay arguments and use
  forcedeth: convert dprintk(KERN_DEBUG to netdev_dbg
  forcedeth: Use print_hex_dump
  forcedeth: Convert remaining dprintk to netdev_dbg
  forcedeth: Use pr_fmt and pr_<level>
  forcedeth: Convert pr_<level> to netdev_<level>
  forcedeth: Add function init_realtek_8211b
  forcedeth: Separate vendor specific initializations into functions
  forcedeth: Convert dev_printk(<level> to dev_<level>(
  forcedeth: Remove netdev_dbg uses
  forcedeth: Use netdev_dbg for printk(KERN_DEBUG

 drivers/net/forcedeth.c |  860 ++++++++++++++++++++---------------------------
 1 files changed, 357 insertions(+), 503 deletions(-)

-- 
1.7.3.2.245.g03276.dirty
