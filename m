From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH  v3 00/13] 2.6.20 Chelsio T3 RDMA Driver
Date: Sun, 10 Dec 2006 16:32:44 -0600
Message-ID: <20061210223244.27166.36192.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, openib-general@openib.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-153-217-226.sw.biz.rr.com ([24.153.217.226]:43551 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759268AbWLJWcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Dec 2006 17:32:45 -0500
To: rdreier@cisco.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Roland, 

I believe all comments so far have been incorporated.

Version 3 changes:

- BugFix: Don't use mutex inside of the mmap function.
- BugFix: Move QP to TERMINATE when TERMINATE AE is processed
- Support the new work queue design
- Merged up to linus's tree as of 12/8/2006
- Misc nits

Version 2 changes:

- Make code sparse endian clean
- Use IDRs for mapping QP and CQ IDs to structure pointers instead
  of arrays
- Clean up confusing bitfields
- Use random32() instead of local random function
- Use krefs to track endpoint reference counts
- Misc nits

-----

The following series implements the Chelsio T3 iWARP/RDMA Driver to
be considered for inclusion in 2.6.20.  It depends on the Chelsio T3
Ethernet driver which is also under review now for 2.6.20. See

http://www.mail-archive.com/netdev@vger.kernel.org/msg27801.html

for the latest posting of the T3 Ethernet driver.

This patch series is against Linus's tree as of 12/8/2006 and can also
be pulled from:

	http://www.opengridcomputing.com/downloads/iw_cxgb3_patches_v3.tar.bz2

The Chelsio T3 Ethernet driver patch can be pulled from:

	http://service.chelsio.com/kernel.org/cxgb3.patch.bz2

A complete GIT kernel tree with all the T3 drivers can be pulled from:

	git://staging.openfabrics.org/~swise/cxgb3.git

Thanks,

Steve.
