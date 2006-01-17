From: "Sean Hefty" <sean.hefty@intel.com>
Subject: [PATCH 0/5] [RFC] Infiniband: connection
	abstraction
Date: Tue, 17 Jan 2006 15:16:04 -0800
Message-ID: <ORSMSX401FRaqbC8wSA0000003e@orsmsx401.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	"'Sean Hefty'" <sean.hefty@intel.com>
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

The following set of patches defines a connection abstraction for Infiniband and
other RDMA devices, and serves several purposes:

* It implements a connection protocol over Infiniband based on IP addressing.
This greatly simplifies clients wishing to establish connections over
Infiniband.

* It defines a connection abstraction that works over multiple RDMA devices.
The submitted implementation targets Infiniband, but has been tested over other
RDMA devices as well.

* It handles RDMA device insertion and removal on behalf of its clients.

The changes have been broken into 5 separate patches.  The basic purpose of each
patch is:

1. Provide common handling for marshalling data between userspace clients and
kernel mode Infiniband 	drivers.

2. Extend the Infiniband CM to include private data comparisons as part of its
connection request matching process.

3. Provide an address translation service that maps IP addresses to Infiniband
addresses (GIDs).  This patch touches outside of the Infiniband core, so I'm
including the netdev mailing list.

4. Implement the kernel mode RDMA connection management agent.

5. Implement the userspace RDMA connection management agent kernel support
module.

Please copy the openib-general mailing list on any replies.

Thanks,
Sean
