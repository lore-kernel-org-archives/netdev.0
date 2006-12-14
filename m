From: "Steve Wise" <swise@opengridcomputing.com>
Subject: [PATCH v4 00/13] 2.6.20 Chelsio T3 RDMA Driver
Date: Thu, 14 Dec 2006 07:52:33 -0600
Message-ID: <20061214135233.21159.78613.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: rdreier@cisco.com
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org


Roland, 

I think this is ready to go once the ethernet driver is pulled in.

Version 4 changes:

- Cleaned up spacing in the Kconfig file
- Remove locking.txt file - its not needed
- Remove -O1 from the debug config option
- BugFix: support new LLD interface for dual-port adapters

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
Ethernet driver which is also under review now for 2.6.20. 

The latest Chelsio T3 Ethernet driver patch can be pulled from:

	http://service.chelsio.com/kernel.org/cxgb3.patch.bz2

A complete GIT kernel tree with all the T3 drivers can be pulled from:

	git://staging.openfabrics.org/~swise/cxgb3.git

Thanks,

Steve.
