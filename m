From: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [RFC 2/3] RDMA/cma: Add support for netlink statistics export
Date: Mon, 16 May 2011 11:05:06 +0300
Message-ID: <4DD0DAB2.1080600@mellanox.com>
References: <1305303525-11113-1-git-send-email-roland@kernel.org>	<1305303525-11113-3-git-send-email-roland@kernel.org> <1828884A29C6694DAF28B7E6B8A82373F428@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1828884A29C6694DAF28B7E6B8A82373F428-P5GAC/sN6hmkrb+BlOpmy7fspsVTdybXVpNB7YpNyf8@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hefty, Sean wrote:
>> +struct rdma_cm_id_stats {
>> +	__u32	qp_num;
>> +	__u32	bound_dev_if;
>> +	__u32	port_space;
>> +	__s32	pid;
>> +	__u8	cm_state;
>> +	__u8	node_type;
>> +	__u8	port_num;
>> +	__u8	reserved;
>> +};
> 
> We may also want to add qp_type

Sean,

Isn't the port space enough here? specifically, what qp type buys us 
over port space?

Or.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
