From: Karsten Keil <kkeil@linux-pingi.de>
Subject: [PATCH 0/8] mISDN: Collection of patches for layer1/layer2
Date: Sat, 28 Apr 2012 13:43:16 +0200
Message-ID: <1335613404-10187-1-git-send-email-kkeil@linux-pingi.de>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:56982 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752983Ab2D1LrW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2012 07:47:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches are mainly the outcome of a TBR3 recertification done
within BT labs.
The patches itself are very well tested more as 10000 valid/invalid
call setup were done in preparartion for the TBR3 aproval.

For net-next.


Andreas Eversberg (1):
  mISDN: Added PH_* state info to tei manager.

Karsten Keil (7):
  mISDN: Fix refcounting bug
  Sometimes the ISDN chip only controls the D-channel
  mISDN: L2 timeouts need to be queued as L2 event
  mISDN: Make layer1 timer 3 value configurable
  mISDN: Layer1 statemachine fix
  mISDN: Help to identify the card
  mISDN: Add 2MBit mode for HFC E1 card

 drivers/isdn/hardware/mISDN/hfc_multi.h |   79 +++---
 drivers/isdn/hardware/mISDN/hfcmulti.c  |  426 ++++++++++++++++++++++++++-----
 drivers/isdn/mISDN/core.c               |   16 ++
 drivers/isdn/mISDN/layer1.c             |   37 ++-
 drivers/isdn/mISDN/layer2.c             |  119 +++++++---
 drivers/isdn/mISDN/socket.c             |    3 +
 drivers/isdn/mISDN/tei.c                |   71 ++++--
 include/linux/mISDNhw.h                 |    6 +
 include/linux/mISDNif.h                 |   71 ++++--
 9 files changed, 649 insertions(+), 179 deletions(-)

-- 
1.7.3.4
