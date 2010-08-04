From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 0/6] bna: Brocade 10Gb Ethernet device driver
Date: Tue, 3 Aug 2010 20:00:28 -0700
Message-ID: <201008040300.o7430SAZ031698@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ddutt@brocade.com>, <huangj@brocade.com>, <rmody@brocade.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:36457 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757520Ab0HDDVX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 23:21:23 -0400
Received: from pps.filterd (m0000542 [127.0.0.1])
	by mx0a-000f0801.pphosted.com (8.14.3/8.14.3) with SMTP id o742ne9e028683
	for <netdev@vger.kernel.org>; Tue, 3 Aug 2010 20:00:29 -0700
Received: from hq-exedge.brocade.com (hq-exedge.brocade.com [66.243.153.83])
	by mx0a-000f0801.pphosted.com with ESMTP id qex9w81yf-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 03 Aug 2010 20:00:29 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>

This is patch 0/6 which contains the summary of changes we've
done in this particular submission for Brocade's BR1010/BR1020
10Gb CEE capable ethernet adapter. Source is based against
net-next-2.6.

The changes are as follows:

1) Addressed comments received so far.

- Added GRO support and removed LRO completely

- Used OS primitives in place of abstractions wherever possible

- Removed duplication of PCI_DEVICE_IDs

- Corrected bnad_netpoll implementation

- Eliminated firmware image copy

- Reduced module parameters to only 2

- Return type of bnad_xmit_start() changed to netdev_tx_t

- Removed unnecessary comments in the code

- Flattened the directory structure and reduced the number of files (form ~45 to 25)

2) Added support for new hardware (e.g. IBM/Dell Mezzanine cards)

We wish this patch to be considered for inclusion in net-next-2.6.

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 0 files changed


