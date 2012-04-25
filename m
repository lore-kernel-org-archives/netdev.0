From: Karsten Keil <kkeil@linux-pingi.de>
Subject: [PATCH 0/4] mISDN Fix and enhancements for the HFC 4S/8S/E1 driver
Date: Wed, 25 Apr 2012 08:52:10 +0200
Message-ID: <1335336734-25181-1-git-send-email-kkeil@linux-pingi.de>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:62245 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750821Ab2DYGzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 02:55:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For net-next.

Patchset contains fixes for issues fond in long time testing.
The LED support now works as proposed by the card documentation.
For special cases you can now split a E1 line into independ logical
instances.

Andreas Eversberg (4):
  mISDN: Fixed false interruption of audio during bridging change.
  mISDN: Using FLG_ACTIVE flag to determine if layer 1 is active or
    not.
  mISDN: Rework of LED status display for HFC-4S/8S/E1 cards.
  mISDN: Added support for fragmentation of E1 interfaces of hfcmulti
    driver.

 drivers/isdn/hardware/mISDN/hfc_multi.h |   15 +-
 drivers/isdn/hardware/mISDN/hfcmulti.c  |  582 ++++++++++++++++++-------------
 2 files changed, 347 insertions(+), 250 deletions(-)

-- 
1.7.3.4
