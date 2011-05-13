From: "Hefty, Sean" <sean.hefty@intel.com>
Subject: RE: [RFC 2/3] RDMA/cma: Add support for netlink statistics export
Date: Fri, 13 May 2011 17:21:02 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A82373F428@ORSMSX101.amr.corp.intel.com>
References: <1305303525-11113-1-git-send-email-roland@kernel.org>
 <1305303525-11113-3-git-send-email-roland@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Roland Dreier <roland@kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:51818 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759728Ab1EMRVF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 13:21:05 -0400
In-Reply-To: <1305303525-11113-3-git-send-email-roland@kernel.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +struct rdma_cm_id_stats {
> +	__u32	qp_num;
> +	__u32	bound_dev_if;
> +	__u32	port_space;
> +	__s32	pid;
> +	__u8	cm_state;
> +	__u8	node_type;
> +	__u8	port_num;
> +	__u8	reserved;
> +};

We may also want to add qp_type
