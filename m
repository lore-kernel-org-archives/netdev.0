From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net 1/2] r8152: fix the sw rx checksum is unavailable
Date: Thu, 24 Nov 2016 11:19:07 -0500 (EST)
Message-ID: <20161124.111907.890044153075333621.davem@davemloft.net>
References: <0835B3720019904CB8F7AA43166CEEB201051D51@RTITMBSV03.realtek.com.tw>
        <95fa9f67-3af6-6749-0e2b-c95406486f7d@pobox.com>
        <baf5246d-9d8a-4029-6823-350ed561fd33@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: mlord-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <baf5246d-9d8a-4029-6823-350ed561fd33-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Mark Lord <mlord-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Date: Thu, 24 Nov 2016 07:31:17 -0500

> Any way we look at it though, the chip/driver are simply unreliable,
> and relying upon hardware checksums (which fail due to the driver
> looking at garbage rather than the checksum bits) leads to data
> corruption.

If the cpu/DMA implementation is the problem, then turning off
checksums is not an appropriate fix at all.

In fact, we have no idea what the cause is yet.

That makes turning off random features no more than grasping at straws
and makes no sense at all upstream.

It may make sense for you to do such a change locally in _your_ tree
to fix your situation temporarily.  But upstream we shouldn't be doing
it.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
