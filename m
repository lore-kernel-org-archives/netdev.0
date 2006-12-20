From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH  v5 00/13] iw_cxgb3 - Chelsio T3 RDMA Driver
Date: Wed, 20 Dec 2006 13:17:54 -0600
Message-ID: <20061220191754.19316.4914.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, openib-general@openib.org,
	linux-kernel@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-153-217-226.sw.biz.rr.com ([24.153.217.226]:38346 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1030291AbWLTTRz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Dec 2006 14:17:55 -0500
To: rdreier@cisco.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Roland, 

I think this is ready to go once the ethernet driver is pulled in by Jeff.  

Also: I'm gone after today returning Wednesday Jan 3rd.  I'll address any
new issues when I return.  

Cheers!

Steve.

----

Version 5 changes:

- BugFix: fixed broken endpoint state serialization
- Merged up to linus's tree as of 12/18/2006 (2.6.20-rc1)
- Removed all blank characters at the end of lines

The following series implements the Chelsio T3 iWARP/RDMA Driver to
be considered for inclusion in 2.6.20.  It depends on the Chelsio T3
Ethernet driver which is also under review now for 2.6.20. 

The latest Chelsio T3 Ethernet driver patch can be pulled from:

  http://service.chelsio.com/kernel.org/cxgb3.patch.bz2

This T3 iWARP/RDMA Driver patch series can be pulled from:

  http://www.opengridcomputing.com/downloads/iw_cxgb3_patches_v5.tar.bz2

A complete GIT kernel tree with all the T3 drivers can be pulled from:

  git://staging.openfabrics.org/~swise/cxgb3.git
