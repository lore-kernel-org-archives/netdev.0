From: Catalin Marinas <catalin.marinas@arm.com>
Subject: [PATCH 0/3] smc911x driver updates
Date: Mon, 20 Oct 2008 18:12:11 +0100
Message-ID: <20081020170917.6277.21228.stgit@pc1117.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cam-admin0.cambridge.arm.com ([193.131.176.58]:51629 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756792AbYJTRZS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2008 13:25:18 -0400
Received: from cam-owa2.Emea.Arm.com (cam-owa2.emea.arm.com [10.1.105.18])
	by cam-admin0.cambridge.arm.com (8.12.6/8.12.6) with ESMTP id m9KHCC6e003153
	for <netdev@vger.kernel.org>; Mon, 20 Oct 2008 18:12:12 +0100 (BST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have three patches for the smc911x driver to allow it to be used with
the ARM RealView boards (until recently I used the out-of-tree driver
from SMSC but I need to provide a working default configuration for the
RealView boards without additional patches).


Catalin Marinas (3):
      smc911x: Make the driver safer on SMP
      smc911x: Add IRQ polarity configuration
      smc911x: Allow Kconfig dependency on ARM


 drivers/net/Kconfig     |    2 +-
 drivers/net/smc911x.c   |   36 ++++++++++++++++--------------------
 include/linux/smc911x.h |    1 +
 3 files changed, 18 insertions(+), 21 deletions(-)

-- 
Catalin
