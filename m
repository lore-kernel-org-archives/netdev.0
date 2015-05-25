From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 0/4] cpsw cleanups
Date: Mon, 25 May 2015 11:02:12 +0200
Message-ID: <cover.1432544195.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:33672 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752023AbbEYJCX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 05:02:23 -0400
Received: by wgez8 with SMTP id z8so67860733wge.0
        for <netdev@vger.kernel.org>; Mon, 25 May 2015 02:02:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While working on an out-of-tree customization, I noticed a few minor
problems in the cpsw code.  This series cleans up the issues I found.

Thanks,
Richard


Richard Cochran (4):
  net: cpsw: fix misplaced break statements.
  net: cpsw: remove two unused global functions
  net: cpsw: remove redundant calls enabling dma interrupts.
  net: cpsw: remove redundant calls disabling dma interrupts.

 drivers/net/ethernet/ti/cpsw.c     |  9 ++------
 drivers/net/ethernet/ti/cpsw_ale.c | 45 --------------------------------------
 drivers/net/ethernet/ti/cpsw_ale.h |  2 --
 3 files changed, 2 insertions(+), 54 deletions(-)

-- 
2.1.4
