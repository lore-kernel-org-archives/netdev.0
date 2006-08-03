From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH v5 0/2] iWARP Core Support
Date: Thu, 03 Aug 2006 16:02:38 -0500
Message-ID: <20060803210238.16228.47335.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, openib-general@openib.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-153-218-104.sw.biz.rr.com ([24.153.218.104]:53448 "EHLO
	dell3.ogc.int") by vger.kernel.org with ESMTP id S1751386AbWHCVCj
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 17:02:39 -0400
To: rdreier@cisco.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


With Seans comments resolved...

I also changed iw_addr_get_dgid() to memcpy the gid like the other
functions do.

----

This patchset defines the modifications to the Linux infiniband subsystem
to support iWARP devices.  

The patchset consists of 2 patches:

        1 - New iWARP CM implementation.  
        2 - Core changes to support iWARP.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
Signed-off-by: Steve Wise <swise@opengridcomputing.com>
