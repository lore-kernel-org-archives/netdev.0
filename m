From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: respin of hso patches for linux-2.6.28-rc6 hso_mutex.patch
 [patch 4/6]
Date: Tue, 25 Nov 2008 03:11:50 -0800 (PST)
Message-ID: <20081125.031150.170595881.davem@davemloft.net>
References: <20081125102043.0f318a8d@lxorguk.ukuu.org.uk>
	<20081125.022246.102969955.davem@davemloft.net>
	<20081125104213.03b280c5@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20081125104213.03b280c5-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Date: Tue, 25 Nov 2008 10:42:13 +0000

> That patch series is a complete mix:
> 
> 1, 3 and 6 are network
> 2 is a broken tty layer patch
> 4 is a broken tty layer patch
> 5 is an ok tty layer patch
> 
> 5 will go into the tty tree
> 
> 2 and 4 clash with the tty tree already and don't deal with the tty side
> locking at all sanely.
> 
> So I've no problem with the network parts (1,3,6) going into the netdev
> tree but the other bits will make a mess if they do so.

Actually Alan, can you do me a favor?

These patches were not numbered, and when you say patch N it's ambiguous
(especially since they arrived on the mailing list in a different
order than they arrived in my private inbox, the latter of which is
the order I applied them to my tree).

So please let me know which patches exactly are which and I'll do the
reverting.

Thanks!
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
