From: Wang Jian <lark@linux.net.cn>
Subject: [PATCH 0/2] Fix register misuse in drivers/net/phy/marvel.c
Date: Fri, 11 Jul 2008 08:55:18 +0800
Message-ID: <4876AF76.6020105@linux.net.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: Alexandr Smirnov <asmirnov@ru.mvista.com>,
	Andy Fleming <afleming@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [210.82.31.146] ([210.82.31.146]:37016 "EHLO mx.linux.net.cn"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755395AbYGKBNX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jul 2008 21:13:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These 2 patches fixed misuse of register for 88e1111.

The problem can be reproduced in my powerpc dev board.

With fiber plugged, start the board in u-boot, the fiber link is
established and data transfer is ok. Booting into kernel with current
marvell.c implementation, and "ifconfig ethX up", the fiber link is lost.

The #1 patch fixed this.

The #2 patch is obvious but I can't test it myself because the board I
have using 88e1111 in GMII mode.

Notice: These two patches didn't fix some auto selection problem yet. I
will discuss the problem in seperate email.


