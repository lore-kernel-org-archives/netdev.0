From: "Sean Hefty" <sean.hefty@intel.com>
Subject: [ofa-general] RE: [PATCH] RDMA/CMA: Use neigh_event_send() to
	initiate neighbour discovery.
Date: Wed, 12 Sep 2007 11:13:08 -0700
Message-ID: <000101c7f568$9275b520$ff0da8c0@amr.corp.intel.com>
References: <20070912100025.3190.89259.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: "'Steve Wise'" <swise@opengridcomputing.com>,
	<rdreier@cisco.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070912100025.3190.89259.stgit@dell3.ogc.int>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

>RDMA/CMA: Use neigh_event_send() to initiate neighbour discovery.
>
>Calling arp_send() to initiate neighbour discovery (ND) doesn't do the
>full ND protocol.  Namely, it doesn't handle retransmitting the arp
>request if it is dropped. The function neigh_event_send() does all this.
>Without doing full ND, rdma address resolution fails in the presence of
>dropped arp bcast packets.
>
>Signed-off-by: Steve Wise <swise@opengridcomputing.com>

Acked-by: Sean Hefty <sean.hefty@intel.com>

Roland - can you please queue this up for 2.6.24?
