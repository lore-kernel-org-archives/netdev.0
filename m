From: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC 2/3] RDMA/cma: Add support for netlink statistics export
Date: Thu, 19 May 2011 11:10:20 -0700
Message-ID: <BANLkTin1uVyrzdn_030bGmC=QHtfkvOTNA@mail.gmail.com>
References: <1305303525-11113-1-git-send-email-roland@kernel.org>
 <1305303525-11113-3-git-send-email-roland@kernel.org> <1828884A29C6694DAF28B7E6B8A82373F428@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1828884A29C6694DAF28B7E6B8A82373F428-P5GAC/sN6hmkrb+BlOpmy7fspsVTdybXVpNB7YpNyf8@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, May 13, 2011 at 10:21 AM, Hefty, Sean <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> wr=
ote:
>> +struct rdma_cm_id_stats {
>> + =A0 =A0 __u32 =A0 qp_num;
>> + =A0 =A0 __u32 =A0 bound_dev_if;
>> + =A0 =A0 __u32 =A0 port_space;
>> + =A0 =A0 __s32 =A0 pid;
>> + =A0 =A0 __u8 =A0 =A0cm_state;
>> + =A0 =A0 __u8 =A0 =A0node_type;
>> + =A0 =A0 __u8 =A0 =A0port_num;
>> + =A0 =A0 __u8 =A0 =A0reserved;
>> +};
>
> We may also want to add qp_type

Is there an easy way to get the qp_type from a struct rdma_cm_id?

ie what code needs to go into cma_get_id_stats() to handle this?

Thanks,
  Roland
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
