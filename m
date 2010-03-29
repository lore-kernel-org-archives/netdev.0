From: Sebastien Jan <s-jan@ti.com>
Subject: [RFC PATCH 0/2] ks8851: support for read/write MAC address from EEPROM
Date: Mon, 29 Mar 2010 20:17:16 +0200
Message-ID: <1269886638-11025-1-git-send-email-s-jan@ti.com>
Cc: Abraham Arce <x0066660@ti.com>, Sebastien Jan <s-jan@ti.com>
To: netdev@vger.kernel.org, Ben Dooks <ben@simtec.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:33708 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752028Ab0C2SSP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Mar 2010 14:18:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I needed to program a mac address to the companion eeprom of our ks8851, and
wrote the following patches, which use debug-fs as interface.

I then realized that this seemed not the usual way to access net controller
eeproms (ethtool seems the more standard way).

I am very interesed in getting your feedbacks on the following:
 1) Does it make any sense to you to use this debug-fs interface to read/write
the mac address (advantage: no need for user to know how ks8851 manages the
eeprom / alignment / offset), and can it be upstreamed?
 2) Must a more generic eeprom access be implemented through ethtool (or another
interface?)? Is it the only choice or can it coexist with option 1)? (most of
code would be common)
 3) Any feedback regarding the code itself or anything else is very welcome!

Thanks,
Sebastien

Sebastien Jan (2):
  ks8851: Add support for MAC address write to companion EEPROM
  ks8851: Add support for MAC address read from companion EEPROM

 drivers/net/ks8851.c |  445 ++++++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/ks8851.h |   14 ++-
 2 files changed, 458 insertions(+), 1 deletions(-)

