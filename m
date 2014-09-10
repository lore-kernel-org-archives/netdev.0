From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 0/5] Allow FW size upto 1MB, support for S25FL032P flash and misc. fixes
Date: Wed, 10 Sep 2014 17:44:26 +0530
Message-ID: <1410351271-26428-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	kumaras@chelsio.com, anish@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:42766
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751013AbaIJMIz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 08:08:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch series adds support to allow FW size upto 1MB, support for S25FL032P
flash. Fix t4_flash_erase_sectors to throw an error, when erase sector aren't in
the flash and also warning message when adapters have flashes less than 2Mb.
Adds device id of new adapter and removes device id of debug adapter.

The patches series is created against 'net-next' tree.
And includes patches on cxgb4 driver and cxgb4vf driver.

We have included all the maintainers of respective drivers. Kindly review the
change and let us know in case of any review comments.

Thanks

Hariprasad Shenai (5):
  cxgb4: Allow T4/T5 firmware sizes up to 1MB
  cxgb4: Add support to S25FL032P flash
  cxgb4: Fix t4_flash_erase_sectors() to throw an error when requested
    to erase sectors which aren't in the FLASH
  cxgb4: Add warning msg when attaching to adapters which have FLASHes
    smaller than 2Mb
  cxgb4/cxgb4vf: Add device ID for new adapter and remove for dbg
    adapter

 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |    2 +
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |   27 ++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.h         |    8 +++++-
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |    3 +-
 4 files changed, 37 insertions(+), 3 deletions(-)
