From: Magnus Damm <magnus.damm@gmail.com>
Subject: [PATCH 00/04] smc91x: request bus width using platform data
Date: Wed, 20 Feb 2008 18:57:40 +0900
Message-ID: <20080220095740.22645.36783.sendpatchset@clockwork.opensource.se>
Cc: Magnus Damm <magnus.damm@gmail.com>, lethal@linux-sh.org,
	nico@cam.org, akpm@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.188]:48369 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750928AbYBTKDB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 05:03:01 -0500
Received: by rv-out-0910.google.com with SMTP id k20so1895551rvb.1
        for <netdev@vger.kernel.org>; Wed, 20 Feb 2008 02:02:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches make it possible to request bus width in the platform data.

Instead of keep on updating smc91x.h with board specific configuration,
use platform data to pass along bus width and irq flags to the driver.
This change is designed to be backwards-compatible, so all boards configured
in the header file should just work as usual.

[PATCH 01/04] smc91x: pass along private data
[PATCH 02/04] smc91x: introduce platform data flags
[PATCH 03/04] smc91x: make superh use default config
[PATCH 04/04] smc91x: add insw/outsw to default config

Tested with and without platform data on a SuperH sh7722 MigoR board.

Signed-off-by: Magnus Damm <damm@igel.co.jp>
---

 drivers/net/smc91x.c   |  340 +++++++++++++++++++++++++-----------------------
 drivers/net/smc91x.h   |  336 ++++++++++++++++++++++-------------------------
 include/linux/smc91x.h |   13 +
 3 files changed, 353 insertions(+), 336 deletions(-)
