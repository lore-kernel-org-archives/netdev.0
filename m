From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [Patch 0/3] Hangs with IPoIB when doing PCI error injection
Date: Fri, 28 Mar 2014 16:47:20 -0400 (EDT)
Message-ID: <20140328.164720.2112966893481630828.davem@davemloft.net>
References: <20140327142813.535289178@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	brking-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
To: clsoto-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140327142813.535289178-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: clsoto-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Date: Thu, 27 Mar 2014 09:28:13 -0500

> This patch is to resolve some hangs we are seeing when doing PCI error injection
> to Mellanox Infiniband cards. With this patch we make mlx4 driver send an IB_EVENT_DEVICE_FATAL 
> to the users and added this event to event handlers to avoid these hangs. 
> If IPoIB is in connected mode, then added to cm an event handler and tried to 
> make sure that when it sees the fatal event it does not try to send anymore packet because
> it will not receive any more completions or interrupts. 

I'm assuming Roland will take this in via his tree.

Thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
