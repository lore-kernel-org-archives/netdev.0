From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 6/6] IB: userspace support for RDMA
	connection manager
Date: Mon, 06 Mar 2006 13:33:25 -0800
Message-ID: <adaoe0j5kd6.fsf@cisco.com>
References: <ORSMSX4011XvpFVjCRG00000009@orsmsx401.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: "Sean Hefty" <sean.hefty@intel.com>
In-Reply-To: <ORSMSX4011XvpFVjCRG00000009@orsmsx401.amr.corp.intel.com> (Sean
	Hefty's message of "Mon, 6 Mar 2006 11:21:04 -0800")
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

 > +struct rdma_ucm_query_route_resp {
 > +	__u64 node_guid;
 > +	struct ib_user_path_rec ib_route[2];
 > +	struct sockaddr_in6 src_addr;
 > +	struct sockaddr_in6 dst_addr;
 > +	__u32 num_paths;
 > +	__u8 port_num;
 > +	__u8 reserved[3];
 > +};

Is there a 32-bit/64-bit compatibility problem here?  From a quick
look, struct sockaddr_in6 is not 8-byte aligned.

 - R.
