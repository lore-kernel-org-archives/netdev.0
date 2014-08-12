From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 0/6] Trivial fixes for cxgb4
Date: Tue, 12 Aug 2014 11:09:07 +0530
Message-ID: <1407821953-8711-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	kumaras@chelsio.com, anish@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:43188
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751341AbaHLFdb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2014 01:33:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch series adds support to fix T5 adapter accessing T4 adapter registers,
issue mbox command on correct mbox for physical function, avoid dumping write
only registers, use correct length for adapter part number and support to detect
and display firmware reported errors.

The patches series is created against 'net-next' tree.
And includes patches on cxgb4 driver.

We have included all the maintainers of respective drivers. Kindly review the
change and let us know in case of any review comments.

Thanks

Hariprasad Shenai (6):
  cxgb4: Fix for handling 1Gb/s SFP+ Transceiver Modules
  cxgb4: Fixed the code to use correct length for part number
  cxgb4: Fix T5 adapter accessing T4 adapter registers
  cxgb4: Detect and display firmware reported errors
  cxgb4: Avoid dumping Write-only registers in register dump
  cxgb4: Issue mbox commands on correct mbox

 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   16 +++--
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      |   79 +++++++++++++++++++----
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h    |    2 +
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h   |    4 +
 4 files changed, 84 insertions(+), 17 deletions(-)
