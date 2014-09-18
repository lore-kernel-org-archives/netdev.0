From: Harish Patil <harish.patil@qlogic.com>
Subject: [PATCH net-next 0/2] qlge: Fix compilation warning and update maintainers
Date: Thu, 18 Sep 2014 17:27:23 -0400
Message-ID: <1411075645-21845-1-git-send-email-harish.patil@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-GELinuxNICDev@qlogic.com>,
	<sudarsana.kalluru@qlogic.com>,
	Harish Patil <harish.patil@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:5426 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757158AbaIRWBM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 18:01:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harish Patil <harish.patil@qlogic.com>

This patch series includes the following set of patches:

- Fix the below warning message:
  qlge_main.c:1754: warning: 'lbq_desc' may be used uninitialized in this function

I have made changes according to your earlier feedback:

"Please fix this differently.  The problem is that the compiler can't see that
you've done the !length check at the top of the function, so when it later
sees the while (length > 0) loop, it doesn't know that this loop will always
execute at least once. Just change that loop to a do { } while() loop and
the compiler will be able to see everything."

- Update qlge driver maintainers list

Please apply this series to net-next.

Thanks,
Harish

Harish Patil (1):
   qlge: Fix compilation warning
   Update qlge driver maintainers list

 MAINTAINERS                                  | 6 +++---
 drivers/net/ethernet/qlogic/qlge/qlge_main.c | 4 ++--
 2 files changed, 5 insertions(+), 5 deletions(-)
