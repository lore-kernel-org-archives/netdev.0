From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net-next-2.6 0/11] bnx2x: Bug fixes and enhancements
Date: Mon, 19 Apr 2010 14:13:02 +0300
Message-ID: <1271675582.6900.265.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>,
	"netdev list" <netdev@vger.kernel.org>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2048 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754508Ab0DSLNV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Apr 2010 07:13:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Resubmitting this patch series with the following changes:
- patch 2 VPD: using generic infrastructures for VPD access
- omitting patch 11 (disabling LRO and leaving only GRO on XEN kernel at
compile time)
- omitting patch 10: changing the default queues to 1 on 32 bits system.

We are looking into using kmalloc() instead of vmalloc() to overcome the
issue on 32 bits kernels.

Please consider applying these changes to net-next.

Thanks,
vlad



