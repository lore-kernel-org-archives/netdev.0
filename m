From: John Fastabend <john.r.fastabend@intel.com>
Subject: [PATCH 0/7] Series short description
Date: Fri, 17 Jun 2011 14:16:07 -0700
Message-ID: <20110617211027.26578.11317.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shmulikr@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:2338 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751901Ab1FQVWk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jun 2011 17:22:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series implements improvements to the DCB netlink
interface. This work was done to improve Application handling
and support firmware based LLDP agents.

This adds a multicast group for DCB currently user space has
trouble keeping in sync across multiple applications and with
firmware agents making DCB attribute changes in the driver.

To help support the recently ratified IEEE802.1Qaz extension
which supports multiple APP data entries for the same
selector and protocol fields a series of ieee set and delete
routines were improved and in the delete case added.

Finally the patches 5 and 6 are fixes to currently existing
code.

Please consider for net-next-2.6 inclusion.

---

John Fastabend (7):
      dcb: Add missing error check in dcb_ieee_set()
      dcb: fix return type on dcb_setapp()
      dcb: Add dcb_ieee_getapp_mask() for drivers to query APP settings
      dcb: Add ieee_dcb_delapp() and dcb op to delete app entry
      dcb: Add ieee_dcb_setapp() to be used for IEEE 802.1Qaz APP data
      net: dcbnl, add multicast group for DCB
      dcb: Add DCBX capabilities bitmask to the get_ieee response


 include/linux/dcbnl.h     |    2 
 include/linux/rtnetlink.h |    2 
 include/net/dcbnl.h       |    6 +
 net/dcb/dcbnl.c           |  414 +++++++++++++++++++++++++++++++++++----------
 4 files changed, 334 insertions(+), 90 deletions(-)

-- 
Signature
