From: Karsten Keil <kkeil@linux-pingi.de>
Subject: [PATCHv2 0/7] mISDN: Collection of patches for layer1/layer2
Date: Thu,  3 May 2012 17:47:25 +0200
Message-ID: <1336060052-27119-1-git-send-email-kkeil@linux-pingi.de>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:49984 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757496Ab2ECPxC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 11:53:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Version 2
I removed the PCM only stuff and the 2MBit test mode and will rework
them for a later submit. I added the lowlevel driver changes for the TIMER3
config to this series.

These patches are mainly the outcome of a TBR3 recertification done
within BT labs.
The patches itself are very well tested more as 10000 valid/invalid
call setup were done in preparartion for the TBR3 aproval.

For net-next.


Andreas Eversberg (1):
  mISDN: Added PH_* state info to tei manager.

Karsten Keil (6):
  mISDN: Fix refcounting bug
  mISDN: L2 timeouts need to be queued as L2 event
  mISDN: Make layer1 timer 3 value configurable
  Add L1 timer3 config control to lowlevel drivers
  mISDN: Layer1 statemachine fix
  mISDN: Help to identify the card

 drivers/isdn/hardware/mISDN/avmfritz.c |    5 +-
 drivers/isdn/hardware/mISDN/hfcmulti.c |    5 +-
 drivers/isdn/hardware/mISDN/hfcpci.c   |    5 +-
 drivers/isdn/hardware/mISDN/hfcsusb.c  |    6 +-
 drivers/isdn/hardware/mISDN/netjet.c   |    5 +-
 drivers/isdn/hardware/mISDN/speedfax.c |    5 +-
 drivers/isdn/hardware/mISDN/w6692.c    |    5 +-
 drivers/isdn/mISDN/core.c              |   16 ++++
 drivers/isdn/mISDN/layer1.c            |   38 +++++++---
 drivers/isdn/mISDN/layer2.c            |  120 ++++++++++++++++++++++++--------
 drivers/isdn/mISDN/tei.c               |   71 ++++++++++++++-----
 include/linux/mISDNhw.h                |    3 +
 include/linux/mISDNif.h                |    9 ++-
 13 files changed, 226 insertions(+), 67 deletions(-)

-- 
1.7.3.4
