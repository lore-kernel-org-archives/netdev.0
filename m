From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: [PATCH 0/5] ne: MIPS: platform_driver
Date: Tue, 01 May 2007 00:27:09 +0900 (JST)
Message-ID: <20070501.002709.130239966.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, ralf@linux-mips.org,
	sshtylyov@ru.mvista.com, akpm@linux-foundation.org
To: linux-mips@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.1.175.29]:52947 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423359AbXD3P1I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2007 11:27:08 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently ne.c has some codes to support RBTX49XX boards but it is not
complete.  Instead of adding more hacks to fix it, this patchset add
an generic platform_driver interface to the driver and let RBTX49XX
use it.

[PATCH 1/5] ne: Add platform_driver
[PATCH 2/5] ne: Misc fixes for platform driver.
[PATCH 3/5] ne: Add NEEDS_PORTLIST to control ISA auto-probe
[PATCH 4/5] ne: MIPS: Use platform_driver for ne on RBTX49XX
[PATCH 5/5] MIPS: Drop unnecessary CONFIG_ISA from RBTX49XX

Changes from previous patchset:

* Split some misc fixes from platform_driver patch. (sugested by Jeff Garzik)
* Add NEEDS_PORTLIST to control ISA auto-probe. (sugested by Jeff Garzik)
* Less ifdef CONFIG_PM. (by Andrew Morton)
* Make rbtx4927_ne_init()'s res[] static __initdata. (by Andrew Morton)

---
Atsushi Nemoto
