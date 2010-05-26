From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] net/core: Save the port number a netdevice uses
Date: Wed, 26 May 2010 01:55:26 -0700 (PDT)
Message-ID: <20100526.015526.102555441.davem@davemloft.net>
References: <20100526081702.GA17160@mtldesk030.lab.mtl.com>
	<20100526.013926.28807066.davem@davemloft.net>
	<20100526084523.GA28748@mtldesk030.lab.mtl.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eli-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org,
	yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org
To: eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100526084523.GA28748-8YAHvHwT2UEvbXDkjdHOrw/a8Rv0c6iv@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Eli Cohen <eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Date: Wed, 26 May 2010 11:45:23 +0300

> Do you think we should use dev_id also for the sysfs file name so
> every driver can choose to interpret this field as it chooses to, or
> should I keep the sysfs file name as "port_number"?

What's wrong with using the existing dev_id sysfs file name and saying
that it means the port number of the card?

Nobody, and I really mean nobody, uses this thing any more.

It used to be a way for devices like the qeth driver to get it's
IPV6 EUI48 value set properly for local IPV6 addresses assigned
to the device, but that got fixed in a different way.

So we can use this value however we wish now, and it defaults to zero
for every single device now, and is propagated across VLAN devices,
which is perfect.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
