From: leitao@linux.vnet.ibm.com
Subject: [PATCH] bnx2 patches
Date: Wed, 16 Dec 2009 06:09:23 -0600
Message-ID: <1260965365-14255-1-git-send-email-leitao@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp04.br.ibm.com ([32.104.18.25]:50295 "EHLO
	e24smtp04.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755433AbZLPMKP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2009 07:10:15 -0500
Received: from mailhub3.br.ibm.com (mailhub3.br.ibm.com [9.18.232.110])
	by e24smtp04.br.ibm.com (8.14.3/8.13.1) with ESMTP id nBGC0qh2010151
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2009 10:00:52 -0200
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by mailhub3.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBGCBstr2265228
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2009 10:11:56 -0200
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBGCAAZf009471
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2009 10:10:10 -0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Michael, 

I found two issues on bnx2 on PPC, and I found a way to solve them. 
Although the second patch fixes the bug, I am not 100% sure that 
this is the best way, and I want to hear your opinion. 

Thanks,
Breno

root (2):
  bnx2: fixing a timeout error due not refreshing TX timers correctly
  bnx2: reset_task is crashing the kernel. Fixing it.

 drivers/net/bnx2.c |   14 +++++++++++---
 1 files changed, 11 insertions(+), 3 deletions(-)

