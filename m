From: Debashis Dutt <ddutt@brocade.com>
Subject: Subject: [PATCH 0/6] bna: Brocade 10Gb Ethernet device driver
Date: Fri, 18 Dec 2009 17:28:35 -0800
Message-ID: <200912190128.nBJ1SZuw015428@blc-10-2.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hq-exedge.brocade.com ([66.243.153.82]:46474 "EHLO
	hq-exedge.brocade.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754490AbZLSB2g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 20:28:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Debashis Dutt <ddutt@brocade.com>

This is patch 0/6 which contains the summary of changes we've
done in this particular submission for Brocade's BR1010/BR1020
10Gb CEE capable ethernet adapter. Source is based against
net-next-2.6.

We wish this patch to be considered for inclusion in net-next-2.6.

The changes are as follows:

1. Removed bfa_defs_version.h (David Miller's comments) 

2. Used upper_32_bits & lower_32_bits as appropriate (Stephen Hemminger's
   comments). 

3. Incorporated a couple of patches from Joe Perches
	a) to use kcalloc wherever appropriate
	b) to use pr_level instead of DPRINTK

4. Replaced #defines with readl & writel as required.

5. Upgraded driver version to 2.1.2.1 from 2.1.0.0

We are working on addressing rest of the comments.

Signed-off-by: Debashis Dutt <ddutt@brocade.com>
---
 0 files changed


