From: Magnus Damm <magnus.damm@gmail.com>
Subject: [PATCH 00/04] smc91x: request bus width using platform data V2
Date: Fri, 22 Feb 2008 19:54:56 +0900
Message-ID: <20080222105456.7408.11277.sendpatchset@clockwork.opensource.se>
Cc: Magnus Damm <magnus.damm@gmail.com>, lethal@linux-sh.org,
	nico@cam.org, akpm@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.230]:16945 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754886AbYBVLA2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2008 06:00:28 -0500
Received: by wr-out-0506.google.com with SMTP id c48so584558wra.23
        for <netdev@vger.kernel.org>; Fri, 22 Feb 2008 03:00:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches make it possible to request bus width in the platform data.

Instead of keep on updating smc91x.h with board specific configuration,
use platform data to pass along bus width and irq flags to the driver.
This change is designed to be backwards-compatible, so all boards configured
in the header file should just work as usual.

[PATCH 01/04] smc91x: pass along private data V2
[PATCH 02/04] smc91x: introduce platform data flags V2
[PATCH 03/04] smc91x: add insw/outsw to default config V2
[PATCH 04/04] smc91x: make superh use default config V2

Tested with and without platform data on a SuperH sh7722 MigoR board.

V2 changes the macro argument name to "lp" and adds SMC_DYNAMIC_BUS_CONFIG.

Signed-off-by: Magnus Damm <damm@igel.co.jp>
---

 drivers/net/smc91x.c   |  335 +++++++++++++++++++++++++---------------------
 drivers/net/smc91x.h   |  343 +++++++++++++++++++++++-------------------------
 include/linux/smc91x.h |   13 +
 3 files changed, 359 insertions(+), 332 deletions(-)
