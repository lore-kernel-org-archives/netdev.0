From: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH rdma-next V3 01/10] net/core: Add support for configuring
 VF GUIDs
Date: Sun, 13 Mar 2016 15:44:13 +0200
Message-ID: <CAJ3xEMi2obQO3GRDJm2tNmAWkJ=b_L00pgT4a6v5MOx+kj9Vqg@mail.gmail.com>
References: <1457729923-4526-1-git-send-email-eli@mellanox.com>
	<1457729923-4526-2-git-send-email-eli@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1457729923-4526-2-git-send-email-eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 11, 2016 at 10:58 PM, Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org> wrote:
> Add two new NLAs to support configuration of Infiniband node or port
> GUIDs. New applications can choose to use this interface to configure
> GUIDs with iproute2 with commands such as:
>
> ip link set dev ib0 vf 0 node_guid 00:02:c9:03:00:21:6e:70
> ip link set dev ib0 vf 0 port_guid 00:02:c9:03:00:21:6e:78
>
> A new ndo, ndo_sef_vf_guid is introduced to notify the net device of the
> request to change the GUID.

Hi Dave,

I understand from your patchworks [1], that this is under your review.
Wanted to ask
if you are OK with the patch going upstream through Doug / the rdma
tree along with
the rest of the series and if you want us to see explicit ack from
netdev/you... on this one.

thanks,

Or.

[1] https://patchwork.ozlabs.org/patch/596492/
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
