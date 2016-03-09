From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 0/4] qed: Management firmware updates
Date: Wed, 9 Mar 2016 09:16:22 +0200
Message-ID: <1457507786-6603-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:44938 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751951AbcCIHQv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 02:16:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains several changes to driver interaction with the
management fw.
The biggest [& most significant] change here is a change in the locking
scheme and re-definition of the 'critical section' when accessing shared
resources toward the goal of interacting with the management firmware.

Dave,

Please consider applying this to `net-next'.

Thanks,
Yuval

Sudarsana Reddy Kalluru (1):
  qed: Prevent Multi-function notification of link state

Tomer Tayar (1):
  qed: Rearrange the MCP lock

Yuval Mintz (1):
  qed: Enlrage the drain timeout

Zvi Nachmani (1):
  qed: Notify of transciever changes

 drivers/net/ethernet/qlogic/qed/qed.h     |   3 +
 drivers/net/ethernet/qlogic/qed/qed_hsi.h |  11 ++
 drivers/net/ethernet/qlogic/qed/qed_mcp.c | 292 ++++++++++++++++++++----------
 drivers/net/ethernet/qlogic/qed/qed_mcp.h |  14 +-
 4 files changed, 220 insertions(+), 100 deletions(-)

-- 
1.9.3
