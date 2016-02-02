From: "Franklin S Cooper Jr." <fcooper@ti.com>
Subject: Keystone 2 boards boot failure
Date: Tue, 2 Feb 2016 10:50:41 -0600
Message-ID: <56B0DE61.2000704@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <w-kwok2@ti.com>, <davem@davemloft.net>
To: <m-karicheri2@ti.com>, <netdev@vger.kernel.org>, <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:33286 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754698AbcBBQut (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 11:50:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

Latest mainline is currently failing to boot for Keystone 2
Hawking but I'm assuming its true for other Keystone 2
boards. Bisect shows that this issue popped up after the
patch "netcp: try to reduce type confusion in descriptors"
(commit 89907779) was introduced. There was another patch
"netcp: fix regression in receive processing" that seems to
fix some bugs that the prior patch introduced however it
still did not resolve the boot failure and was documented as
not being tested.

Should we revert these commits or does anyone have any
suggestions on how to fix these failures? I would be more
than happy to test any fix.

Bootlogs:
Bootlog 4.5.0-rc2: http://pastebin.com/bsH4u656 (Failed)
Bootlog 4.5.0-rc1: http://pastebin.com/MwY0eS7x (Failed)
Bootlog 4.4: http://pastebin.com/yfBND9Vi (Passed)
