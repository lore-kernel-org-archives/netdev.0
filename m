From: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] mlx4_en: show device's port used
Date: Tue, 25 May 2010 14:32:26 -0700
Message-ID: <adask5fy8et.fsf@roland-alpha.cisco.com>
References: <20100525135548.GA12749@mtldesk030.lab.mtl.com>
	<adaaarnzzsc.fsf@roland-alpha.cisco.com>
	<20100525174214.GA14745@mtldesk030.lab.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eli Cohen <eli-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux RDMA list <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org
To: Eli Cohen <eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100525174214.GA14745-8YAHvHwT2UEvbXDkjdHOrw/a8Rv0c6iv@public.gmane.org> (Eli Cohen's
	message of "Tue, 25 May 2010 20:42:14 +0300")
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

 > I don't think there are many devices out there which have more than
 > one port.

??

http://developer.intel.com/network/connectivity/solutions/gigabit.htm
http://www.broadcom.com/products/Ethernet-Controllers/Enterprise-Server/BCM5704C

etc

 > So this will require changing all the drivers to put some value there
 > or we would need to use a default value of 1 for drivers that don't
 > explicitly set a value.

Yes, just set a default value.

 > > and export it to userspace in generic code (so everyone
 > > does it the same way).

 > Something like ethtool? But we still need an entry under
 > /sys/class/net/ethx/, right?

It could be ethtool or a sysfs attr.

 - R.
-- 
Roland Dreier <rolandd-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org> || For corporate legal information go to:
http://www.cisco.com/web/about/doing_business/legal/cri/index.html
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
