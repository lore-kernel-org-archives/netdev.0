From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] remove broken and unmaintained Sangoma drivers
Date: Tue, 4 Apr 2006 18:36:51 +0200
Message-ID: <20060404163651.GR6529@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Mandelstam <dm@sangoma.com>,
	Nenad Corbic <ncorbic@sangoma.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750768AbWDDQgy@vger.kernel.org>
To: jgarzik@pobox.com
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The in-kernel Sangoma drivers are both not compiling and marked as 
BROKEN since at least kernel 2.6.0.

Sangoma offers out-of-tree drivers, and David Mandelstam told me Sangoma 
does no longer maintain the in-kernel drivers and prefers to provide 
them as a separate installation package.

This patch therefore removes these drivers.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

Due to it's size, the patch is available at
ftp://ftp.kernel.org/pub/linux/kernel/people/bunk/misc/patch-remove-sangoma.gz

 MAINTAINERS                       |    7 
 drivers/net/wan/Kconfig           |   97 
 drivers/net/wan/Makefile          |   13 
 drivers/net/wan/sdla_chdlc.c      | 4428 ------------------------
 drivers/net/wan/sdla_fr.c         | 5061 ---------------------------
 drivers/net/wan/sdla_ft1.c        |  345 -
 drivers/net/wan/sdla_ppp.c        | 3430 ------------------
 drivers/net/wan/sdla_x25.c        | 5497 ------------------------------
 drivers/net/wan/sdladrv.c         | 2314 ------------
 drivers/net/wan/sdlamain.c        | 1346 -------
 drivers/net/wan/wanpipe_multppp.c | 2358 ------------
 include/linux/sdla_asy.h          |  226 -
 include/linux/sdla_chdlc.h        |  813 ----
 include/linux/sdla_ppp.h          |  575 ---
 include/linux/sdla_x25.h          |  772 ----
 include/linux/sdladrv.h           |   66 
 include/linux/sdlapci.h           |   72 
 include/linux/sdlasfm.h           |  104 
 include/linux/wanpipe.h           |  483 --
 net/wanrouter/af_wanpipe.c        |    2 
 20 files changed, 28009 deletions(-)
