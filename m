From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] net/core: Save the port number a netdevice uses
Date: Wed, 02 Jun 2010 10:12:22 -0700 (PDT)
Message-ID: <20100602.101222.51286679.davem@davemloft.net>
References: <20100526090850.GB28748@mtldesk030.lab.mtl.com>
	<20100526.021635.179940939.davem@davemloft.net>
	<1275496949.2115.18.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org,
	yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org
To: bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1275496949.2115.18.camel-xQnnTUlwzDrdvaEqJLTMTA9jg9n5Vt1AMm0uRHvK7Nw@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Date: Wed, 02 Jun 2010 17:42:29 +0100

> On Wed, 2010-05-26 at 02:16 -0700, David Miller wrote:
>> From: Eli Cohen <eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
>> Date: Wed, 26 May 2010 12:08:52 +0300
>> 
>> > So if I understand you correctly, you think that I should not bother
>> > to set a default value of 1. Each driver that cares about the value
>> > of this field, will set it however they want.
>> 
>> I actually mean that the value "0" should mean the first port,
>> the value "1" should mean the second port, etc.
> 
> There's a compatibility problem here though: when user-space looks at
> this number it can't tell whether "0" really means the first port or
> that the driver isn't setting dev_id.

That's perfect, it means we don't have to add explicit settings to
drivers which driver only one port.  Ie. the vast majority of
cases.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
