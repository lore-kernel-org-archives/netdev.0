From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH 0/6] iw_cxgb3: Bug Fixes for 2.6.23
Date: Wed, 27 Jun 2007 10:51:19 -0500
Message-ID: <20070627155119.24944.44172.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: general@lists.openfabrics.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, divy@chelsio.com
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]:39332 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754801AbXF0PvS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2007 11:51:18 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hey Roland,

Here are some bug fixes to the iw_cxgb3 driver that I'd like included
for 2.6.23. NOTE: Patch 1 requires a firmware interface change, so
there is a version bump to 4.3 included in that patch that hits cxgb3.
This will likely conflict with a previous version change that is in
Jeff's upstream branch.  The net is: we need the firmware version bumped
to 4.3 with these iw_cxgb3 changes.

Thanks,

Steve.

Shortlog:
      iw_cxgb3: Streaming -> RDMA mode transition fixes.
      iw_cxgb3: TERMINATE WRs can hang the tx ofld queue.
      iw_cxgb3: Don't count neg_adv abort_req_rss messages as real aborts.
      iw_cxgb3: ctrl-qp init/clear shouldn't set the gen bit.
      iw_cxgb3: Don't post TID_RELEASE message.
      iw_cxgb3: Don't abort after failures sending the mpa reply.
