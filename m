From: Magnus Damm <magnus.damm@gmail.com>
Subject: [PATCH 00/05] smc911x: Request bus width using platform data
Date: Mon, 02 Jun 2008 20:37:06 +0900
Message-ID: <20080602113706.28716.92046.sendpatchset@rx1.opensource.se>
Cc: Magnus Damm <magnus.damm@gmail.com>, lethal@linux-sh.org,
	akpm@linux-foundation.org, jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.233]:47685 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748AbYFBLgy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2008 07:36:54 -0400
Received: by rv-out-0506.google.com with SMTP id l9so1003094rvb.1
        for <netdev@vger.kernel.org>; Mon, 02 Jun 2008 04:36:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches make it possible to request bus width using platform data.

Instead of keep on updating smc911x.h with board specific configuration,
use platform data to pass along bus width and irq flags to the driver.
While at it, remove some dead code.

[PATCH 01/05] smc911x: Remove unused 8-bit I/O operations
[PATCH 02/05] smc911x: Fix 16-bit I/O operations
[PATCH 03/05] smc911x: Pass along private data and use iomem
[PATCH 04/05] smc911x: Introduce platform data flags
[PATCH 05/05] smc911x: SuperH architecture support

The smc91x driver has gone through a similar change a few months ago.
http://www.mail-archive.com/netdev@vger.kernel.org/msg62427.html

Signed-off-by: Magnus Damm <damm@igel.co.jp>
---

 drivers/net/Kconfig     |    2 
 drivers/net/smc911x.c   |  423 +++++++++++++++++----------------------
 drivers/net/smc911x.h   |  505 ++++++++++++++++++++++++++---------------------
 include/linux/smc911x.h |   12 +
 4 files changed, 483 insertions(+), 459 deletions(-)
