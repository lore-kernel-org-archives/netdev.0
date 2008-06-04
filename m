From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 0/12]: Proper compat WEXT support.
Date: Wed, 04 Jun 2008 15:48:34 -0700 (PDT)
Message-ID: <20080604.154834.80521372.davem@davemloft.net>
References: <20080603.132755.262737024.davem@davemloft.net>
	<20080604184955.B033.40F06B3A@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: mokuno-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080604184955.B033.40F06B3A-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Masakazu Mokuno <mokuno-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org>
Date: Wed, 04 Jun 2008 19:09:06 +0900

> I'm testing these patches on my PS3.  I've found a problem.
> 
> With 32-bit wireless-tools v28, the bitrates from the scan result were
> wrong (with gelic/rt2x00 driver):

Thanks, I'll look into this when I get a chance.

I want to redesign the interfaces so that the callers give
enough information to the helper routines such that the
compat stuff can be handled completely inside of the
helpers.

It is unpleasant (and error prone) to put this compat handling
at all of the call sites.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
