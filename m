From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 00/39] mv643xx_eth: complete overhaul
Date: Tue,  3 Jun 2008 13:02:15 +0200
Message-ID: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Cc: netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:48746 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753649AbYFCMAZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 08:00:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set completely overhauls the mv643xx_eth driver.

The most important change is probably the eradication of the hardware
abstraction layer code in the driver, but there's also a bunch of new
features, such as initial steps towards multiple RX/TX queues and TX
bandwidth control (global and per queue), proper support for newer
mv643xx_eth versions (where some of the registers have moved around a
bit), and support for operation without a PHY, e.g. in cases where the
ethernet port is directly (over (R)GMII) connected to an ethernet
switch chip.

Any feedback appreciated.

