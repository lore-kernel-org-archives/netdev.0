From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless 2012-05-15
Date: Wed, 16 May 2012 01:06:20 -0400 (EDT)
Message-ID: <20120516.010620.1217035745038191380.davem@davemloft.net>
References: <20120515205157.GF24572@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120515205157.GF24572-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Tue, 15 May 2012 16:51:58 -0400

> Here are three more fixes that some of my developers are desperate to
> see included in 3.4...
> 
> Johan Hedberg went to some length justifyng the inclusion of these two
> Bluetooth fixes:
> 
> "The device_connected fix should be quite self-explanatory, but it's
> actually a wider issue than just for keyboards. All profiles that do
> incoming connection authorization (e.g. headsets) will break without it
> with specific hardware. The reason it wasn't caught earlier is that it
> only occurs with specific Bluetooth adapters.
> 
> As for the security level patch, this fixes L2CAP socket based security
> level elevation during a connection. The HID profile needs this (for
> keyboards) and it is the only way to achieve the security level
> elevation when using the management interface to talk to the kernel
> (hence the management enabling patch being the one that exposes this"
> 
> The rtlwifi fix addresses a regression related to firmware loading,
> as described in kernel.org bug 43187.  It basically just moves a hunk
> of code to a more appropriate place.

Pulled, and the above text gave me something to put into the merge
commit log message, thanks :-)
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
