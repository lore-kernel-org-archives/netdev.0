From: Rasesh Mody <rmody@brocade.com>
Subject: Subject: [PATCH 0/6] bna: Brocade 10Gb Ethernet device driver
Date: Tue, 17 Nov 2009 00:30:55 -0800
Message-ID: <200911170830.nAH8Ut5G010599@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hq-exedge.brocade.com ([66.243.153.83]:40636 "EHLO
	hq-exedge.brocade.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754638AbZKQIax (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 03:30:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>

This is patch 0/6 which contains the summary of changes we've
done in this perticular submission for Brocade's BR1010/BR1020
10Gb CEE capable ethernet adapter. Source is based against
net-next-2.6.

We wish this patch to be considered for inclusion in net-next-2.6.

We have addressed the following list of review comments:

1. Removed bfa_cb_queue macros and the corresponding file, #define WWN_NULL, Replaced MAC_ADDRLEN with ETH_ALEN

2. Removed lun_t

3. Removed references to LICENSE.bna

4. Using cpu_to_be64 in bna_dma_addr64() instead of swab64()

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 0 files changed


