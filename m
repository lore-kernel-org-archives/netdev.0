From: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Subject: How to debug DMAR errors?
Date: Thu, 13 Apr 2017 11:12:12 -0700
Message-ID: <a21d8845-ae8d-fae0-b1b4-7bf6751b04b5@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello,

I have been seeing a regular occurrence of DMAR errors, looking something
like this when testing my ath10k driver/firmware under some specific loads
(maximum receive of 512 byte frames in AP mode):

DMAR: DRHD: handling fault status reg 3
DMAR: [DMA Read] Request device [05:00.0] fault addr fd99f000 [fault reason 06] PTE Read access is not set
ath10k_pci 0000:05:00.0: firmware crashed! (uuid 594b1393-ae35-42b5-9dec-74ff0c6791ff)

So, I am wondering if there is any way I can get more information about what this fd99f000 address
is?

Once this problem hits, the entire OS locks hard (not even sysrq-boot will do anything),
so I guess I would need the DMAR logic to print out more info on that address somehow.

Thanks,
Ben

-- 
Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Candela Technologies Inc  http://www.candelatech.com
