From: Rasesh Mody <rmody@brocade.com>
Subject: Subject: [PATCH 0/6] bna: Brocade 10Gb Ethernet device driver
Date: Mon, 23 Nov 2009 19:51:01 -0800
Message-ID: <200911240351.nAO3p1K1025621@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hq-exedge.brocade.com ([66.243.153.83]:50252 "EHLO
	hq-exedge.brocade.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757884AbZKXDuz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 22:50:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>

This is patch 0/6 which contains the summary of changes we've
done in this perticular submission for Brocade's BR1010/BR1020
10Gb CEE capable ethernet adapter. Source is based against
net-next-2.6.

We wish this patch to be considered for inclusion in net-next-2.6.

We have addressed the following list of review comments and some some additional changes from our side:

1. Fixed include file names and there by assumption that current working directory is in the header search path

2. Added const qualifier to global variables where appropriate for compiler optimization. 

3. Using bool instead of int wherever appropriate to reduce space consumption

4. Used OS defined macros BUG_ON, ALIGN & DIV_ROUND_UP, wherever possible

5. Removed inappropriate netif_carrier_ok() tests

6. Removed useless prefetch() from Rx path

7. Replaced dev_kfree_skb_any() with the less expensive dev_kfree_skb() in bnad_poll_cq() since this is always called from NAPI poll context.

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 0 files changed


