From: John Fastabend <john.r.fastabend@intel.com>
Subject: [PATCH 0/7] Series short description
Date: Fri, 17 Jun 2011 14:08:00 -0700
Message-ID: <20110617210729.26344.17037.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shmulikr@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:43054 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751254Ab1FQVOc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jun 2011 17:14:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series implements...

---

John Fastabend (7):
      dcb: Add missing error check in dcb_ieee_set()
      dcb: fix return type on dcb_setapp()
      dcb: Add dcb_ieee_getapp_mask() for drivers to query APP settings
      dcb: Add ieee_dcb_delapp() and dcb op to delete app entry
      dcbnl: Add ieee_dcb_setapp() to be used for IEEE 802.1Qaz APP data
      net: dcbnl, add multicast group for DCB
      Add DCBX capabilities bitmask to the get_ieee response.


 include/linux/dcbnl.h     |    2 
 include/linux/rtnetlink.h |    2 
 include/net/dcbnl.h       |    6 +
 net/dcb/dcbnl.c           |  414 +++++++++++++++++++++++++++++++++++----------
 4 files changed, 334 insertions(+), 90 deletions(-)

-- 
Signature
