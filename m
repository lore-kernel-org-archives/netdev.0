From: Sujith Manoharan <sujith-TPRpbcbO+rZAfugRpC6u6w@public.gmane.org>
Subject: Re: [ath9k-devel] ath9k channel switch
Date: Sun, 15 Mar 2015 08:09:24 +0530
Message-ID: <21764.61660.411242.223378@gargle.gargle.HOWL>
References: <CAGrUaU24vCH6+GpAtBCNiGwdT4_-FNNLDq=_s5zhSPBOp8bbmg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org, ath9k-devel-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org
To: Saurabh Pal <saurabh6321-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAGrUaU24vCH6+GpAtBCNiGwdT4_-FNNLDq=_s5zhSPBOp8bbmg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Saurabh Pal wrote:
> Just wanted to know whether it is possible to switch the channel without
> resetting the chip. Also if possible can anybody tell me how much time it
> takes to switch the channel by resetting the chip?

Fast Channel Change is used to switch channels without a full chip reset.
The time taken to switch channels is not exported, but you can measure it
in the driver.

Sujith
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
