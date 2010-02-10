From: Rasesh Mody <rmody@brocade.com>
Subject: Subject: [PATCH 0/6] bna: Brocade 10Gb Ethernet device driver
Date: Tue, 9 Feb 2010 22:29:15 -0800
Message-ID: <201002100629.o1A6TFjv026359@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: adapter_linux_open_src_team@brocade.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hq-exedge.brocade.com ([66.243.153.83]:53612 "EHLO
	hq-exedge.brocade.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751449Ab0BJGeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 01:34:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>

This is patch 0/6 which contains the summary of changes we've
done in this particular submission for Brocade's BR1010/BR1020
10Gb CEE capable ethernet adapter. Source is based against
net-next-2.6.

The changes are as follows:

1) Frimware changes:
	Releasing the firmware buffer
	Using global mutex for synchronizing firmware read
	Using MODULE_FIRMWARE for firmware dependencies

2) Got rid of extra message buffers

3) Using kernel Timers 

4) Removed perm_addr from bnad structure

5) Using roundup in place of DIV_ROUND_UP

6) Miscellaneous cleanup

We wish this patch to be considered for inclusion in net-next-2.6.

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 0 files changed


