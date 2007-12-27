From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: : Emit event stream compat iw_point objects correctly.
Date: Thu, 27 Dec 2007 01:26:56 -0800 (PST)
Message-ID: <20071227.012656.59032711.davem@davemloft.net>
References: <20071227173802.6F56.40F06B3A@sm.sony.co.jp>
	<20071227.005725.144782426.davem@davemloft.net>
	<20071227181439.6F59.40F06B3A@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: mokuno-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20071227181439.6F59.40F06B3A-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Masakazu Mokuno <mokuno-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org>
Date: Thu, 27 Dec 2007 18:24:40 +0900

> On ppc64 (PS3), IW_EV_LCP_LEN is 8, not 4.
> 
> include/linux/wireless.h:
> 
> #define IW_EV_LCP_LEN   (sizeof(struct iw_event) - sizeof(union iwreq_data))
> 
> where sizeof(struct iw_event) == 24, sizeof(union iwreq_data) == 16 on
> PS3.

Hmmm, I will look into this, thank you :-)
