From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH  v2 00/13] 2.6.20 Chelsio T3 RDMA Driver
Date: Sat, 02 Dec 2006 16:49:17 -0600
Message-ID: <20061202224917.27014.15424.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, openib-general@openib.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-153-217-226.sw.biz.rr.com ([24.153.217.226]:17305 "EHLO
	smtp.opengridcomputing.com") by vger.kernel.org with ESMTP
	id S936579AbWLBWtS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Dec 2006 17:49:18 -0500
To: rdreier@cisco.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Version 2 changes:

- Make code sparse endian clean
- Use IDRs for mapping QP and CQ IDs to structure pointers instead of arrays
- Clean up confusing bitfields
- Use random32() instead of local random function
- Use krefs to track endpoint reference counts
- Misc nits

-----

The following series implements the Chelsio T3 iWARP/RDMA Driver to
be considered for inclusion in 2.6.20.  It depends on the Chelsio T3
Ethernet Driver which is also under review now for 2.6.20. See:

http://www.mail-archive.com/netdev@vger.kernel.org/msg26619.html

The patches are against 2.6.19.

This patch series can also be pulled from:

	http://www.opengridcomputing.com/downloads/iw_cxgb3_patches_v2.tar.bz2

The Chelsio T3 Ethernet Driver patch can be pulled from:

	http://service.chelsio.com/kernel.org/cxgb3.patch.bz2

A complete GIT kernel tree with all the T3 drivers can be pulled from:

	git://staging.openfabrics.org/~swise/cxgb3.git

Thanks,

Steve.
