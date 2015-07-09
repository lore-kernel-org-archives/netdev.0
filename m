From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v1 02/12] IB/core: Find the network device matching connection
 parameters
Date: Thu, 9 Jul 2015 13:18:36 +0300
Message-ID: <559E4A7C.8020606@mellanox.com>
References: <1434976961-27424-1-git-send-email-haggaie@mellanox.com>
 <1434976961-27424-3-git-send-email-haggaie@mellanox.com>
 <20150708203325.GB16812@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150708203325.GB16812-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 08/07/2015 23:33, Jason Gunthorpe wrote:
> On Mon, Jun 22, 2015 at 03:42:31PM +0300, Haggai Eran wrote:
>> +/**
>> + * ib_get_net_dev_by_params() - Return the appropriate net_dev
>> + * for a received CM request
>> + * @dev:	An RDMA device on which the request has been received.
>> + * @port:	Port number on the RDMA device.
>> + * @pkey:	The Pkey the request came on.
>> + * @gid:	A GID that the net_dev uses to communicate.
>> + * @addr:	Contains the IP address that the request specified as its
>> + *		destination.
>> + */
>> +struct net_device *ib_get_net_dev_by_params(struct ib_device *dev, u8 port,
>> +					    u16 pkey, const union ib_gid *gid,
>> +					    const struct sockaddr *addr);
> 
> I feel like this has been repated a few times now, but kdocs should be
> with the function body, not in the header.
Right. I fixed it in the IB/addr patch, but missed it here. I'll move it
to the function's definition.

> Reviewed-By: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Thanks,

Haggai

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
